#pragma once
// Per-file persistence of coordinator presets under <repo>/presets/.
//
// In addition to the embedded `coordinator.presets` section of the swarm
// config, each saved preset is mirrored to its own presets/<name>.json file so
// presets live as real, individually-shareable files that survive a redeploy.
// On startup the directory is the source of truth (files win over the embedded
// section). Header-only; included by the preset routes and coordinator setup.

#include "swarm_config_store.h"   // SwarmPaths
#include "json.hpp"
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

namespace presets_dir {

namespace fs = std::filesystem;
using json = nlohmann::json;

// Reject separators / traversal so a preset name can only ever map to a file
// directly inside the presets dir. Returns "" (with no side effects) if unsafe.
inline std::string safe_filename(const std::string& name) {
    if (name.empty() || name == "." || name == "..") return "";
    for (char c : name) {
        if (c == '/' || c == '\\' || c == '\0') return "";
    }
    return name;
}

// presets/ lives next to the source swarm-config.json (repo root), falling back
// to the active config's directory when no source path is configured.
inline std::string dir_for(const SwarmPaths& paths) {
    const std::string base = !paths.source_config_path.empty()
        ? paths.source_config_path : paths.active_config_path;
    fs::path p(base);
    fs::path parent = p.has_parent_path() ? p.parent_path() : fs::path(".");
    return (parent / "presets").string();
}

// Write presets/<name>.json. Logs and returns false on any failure.
inline bool write_file(const SwarmPaths& paths,
                       const std::string& name, const json& bundle) {
    const std::string fname = safe_filename(name);
    if (fname.empty()) {
        std::cerr << "❌ [presets-dir] unsafe preset name rejected: '"
                  << name << "'" << std::endl;
        return false;
    }
    const std::string dir = dir_for(paths);
    std::error_code ec;
    fs::create_directories(dir, ec);
    if (ec) {
        std::cerr << "❌ [presets-dir] cannot create " << dir
                  << ": " << ec.message() << std::endl;
        return false;
    }
    const std::string path = (fs::path(dir) / (fname + ".json")).string();
    std::ofstream out(path);
    if (!out.is_open()) {
        std::cerr << "❌ [presets-dir] cannot write " << path << std::endl;
        return false;
    }
    out << bundle.dump(2) << std::endl;
    std::cout << "💾 [presets-dir] wrote " << path << std::endl;
    return true;
}

// Remove presets/<name>.json. A missing file is success; returns false (with a
// log) only on a real filesystem error.
inline bool remove_file(const SwarmPaths& paths, const std::string& name) {
    const std::string fname = safe_filename(name);
    if (fname.empty()) return false;
    const std::string path =
        (fs::path(dir_for(paths)) / (fname + ".json")).string();
    std::error_code ec;
    fs::remove(path, ec);
    if (ec) {
        std::cerr << "❌ [presets-dir] cannot remove " << path
                  << ": " << ec.message() << std::endl;
        return false;
    }
    return true;
}

// Load every presets/*.json into `presets`, keyed by filename stem. Files on
// disk overwrite config-embedded entries of the same name. Returns the count
// loaded. Per-file parse errors are logged and skipped, never fatal.
inline int load_into(const SwarmPaths& paths, json& presets) {
    const std::string dir = dir_for(paths);
    std::error_code ec;
    if (!fs::exists(dir, ec)) return 0;
    int n = 0;
    for (const auto& entry : fs::directory_iterator(dir, ec)) {
        if (ec) {
            std::cerr << "❌ [presets-dir] cannot scan " << dir
                      << ": " << ec.message() << std::endl;
            break;
        }
        if (!entry.is_regular_file() || entry.path().extension() != ".json")
            continue;
        std::ifstream in(entry.path());
        if (!in.is_open()) {
            std::cerr << "❌ [presets-dir] cannot read "
                      << entry.path().string() << std::endl;
            continue;
        }
        try {
            json bundle;
            in >> bundle;
            presets[entry.path().stem().string()] = bundle;
            ++n;
        } catch (const std::exception& e) {
            std::cerr << "❌ [presets-dir] bad JSON in "
                      << entry.path().string() << ": " << e.what() << std::endl;
        }
    }
    if (n > 0)
        std::cout << "🎛️  [presets-dir] loaded " << n
                  << " preset file(s) from " << dir << std::endl;
    return n;
}

} // namespace presets_dir
