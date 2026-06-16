#include "httplib.h"
#include "matrix_env.h"
#include "proxy_routes.h"

#include <iostream>
#include <string>
#include <cstdlib>

int main(int /*argc*/, char* argv[]) {
    // Project root = where swarm-config.json / config/coordinator.json / agent_logs
    // live and runtime state is written. The launcher stages a writable run dir and
    // passes it via MATRIX_PROJECT_ROOT; fall back to the executable's own directory
    // (source/dev checkout, where the binary sits at the repo root).
    std::string proj_root;
    if (const char* pr = std::getenv("MATRIX_PROJECT_ROOT"); pr && pr[0]) {
        proj_root = pr;
    } else {
        proj_root = argv[0];
        if (auto sl = proj_root.rfind('/'); sl != std::string::npos)
            proj_root = proj_root.substr(0, sl);
        else proj_root = ".";
    }

    matrix_env_init(proj_root);

    httplib::Server svr;
    svr.set_read_timeout(660, 0);
    svr.set_write_timeout(660, 0);

    register_proxy_routes(svr, proj_root);

    // Bind host — MATRIX_BIND_HOST pins loopback for the non-networked desktop
    // license; default 0.0.0.0 (server/dev).
    const char* bh = std::getenv("MATRIX_BIND_HOST");
    const std::string bind_host = (bh && bh[0]) ? bh : "0.0.0.0";
    std::cout << "Matrix Proxy active on http://" << bind_host << ":" << g_env.proxy_port << "\n";
    std::cout << "  MATRIX_MODEL_DIR=" << g_env.model_dir << "\n";
    std::cout << "  MATRIX_LLAMA_SERVER=" << g_env.llama_server_bin << "\n";
    svr.listen(bind_host.c_str(), g_env.proxy_port);
    return 0;
}
