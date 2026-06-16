#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CPP_SRC="$ROOT/cpp_core/src"
mkdir -p "$ROOT/build/modes" "$ROOT/bin"
PKG_JSON="$ROOT/package.json"
MATRIX_VERSION="dev"
if [ -f "$PKG_JSON" ]; then
  v="$(sed -nE 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$PKG_JSON" | head -1)"
  [ -n "$v" ] && MATRIX_VERSION="$v"
fi
MOD_OBJS=()
for f in "$CPP_SRC/modes"/*.cpp; do
  base=$(basename "$f" .cpp)
  obj="$ROOT/build/modes/${base}.o"
  c++ -std=c++17 -O2 -c -o "$obj" "$f" -I"$CPP_SRC"
  MOD_OBJS+=("$obj")
done
ar rcs "$ROOT/build/libmatrix_modes.a" "${MOD_OBJS[@]}"
uname_s="$(uname -s)"
MOD_LINK=()
if [ "$uname_s" = "Darwin" ]; then
  MOD_LINK+=( -Wl,-force_load,"$ROOT/build/libmatrix_modes.a" )
else
  MOD_LINK+=( -Wl,--whole-archive "$ROOT/build/libmatrix_modes.a" -Wl,--no-whole-archive )
fi
PROM_INC_FLAGS=() PQ_INC_FLAGS=()
PROM_LINK=(-lprometheus-cpp-core) PQ_LINK=(-lpq)
if [ "$uname_s" = "Darwin" ]; then
  BREW_PREFIX="$( (command -v brew >/dev/null 2>&1 && brew --prefix) || echo /opt/homebrew )"
  PROM_INC_FLAGS=(-I"$BREW_PREFIX/include" -L"$BREW_PREFIX/lib")
  PQ_INC_FLAGS=(-I"$BREW_PREFIX/opt/libpq/include" -L"$BREW_PREFIX/opt/libpq/lib")
fi
cc -std=c99 -O2 -c -o "$ROOT/build/blake2b.o" "$CPP_SRC/blake2b.c"
c++ -std=c++17 -O2 -DMATRIX_VERSION="\"${MATRIX_VERSION}\"" -o "$ROOT/bin/cofiswarm-coordinator" \
  "${PROM_INC_FLAGS[@]}" "${PQ_INC_FLAGS[@]}" \
  "$CPP_SRC/coordinator.cpp" "$CPP_SRC/coordinator_setup.cpp" \
  "$CPP_SRC/config/swarm_config_resolve.cpp" \
  "$CPP_SRC/config/coordinator_config_validate.cpp" \
  "$CPP_SRC/config/swarm_config_dir_load.cpp" "$CPP_SRC/config/path_expand.cpp" \
  "$CPP_SRC/telemetry.cpp" "$CPP_SRC/coordinator_context.cpp" \
  "$CPP_SRC/mode_module.cpp" "$CPP_SRC/session_store.cpp" \
  "$CPP_SRC/session_store_text.cpp" "$CPP_SRC/token_ledger.cpp" \
  "$CPP_SRC/rss_generator.cpp" "$CPP_SRC/synthesis_budget.cpp" \
  "$CPP_SRC/synthesis_budget_assemble.cpp" "$CPP_SRC/synthesis_tiered.cpp" \
  "$CPP_SRC/coordinator_routes.cpp" "$CPP_SRC/coordinator_routes_mlx.cpp" \
  "$CPP_SRC/mlx_session_store.cpp" \
  "$CPP_SRC/coordinator_routes_agents_meta.cpp" \
  "$CPP_SRC/coordinator_routes_agent_tokens.cpp" \
  "$CPP_SRC/coordinator_routes_core.cpp" \
  "$CPP_SRC/coordinator_routes_dispatch.cpp" \
  "$CPP_SRC/coordinator_routes_dispatch_prepare.cpp" \
  "$CPP_SRC/coordinator_routes_architect_stream.cpp" \
  "$CPP_SRC/coordinator_routes_architect_stream_modes.cpp" \
  "$CPP_SRC/coordinator_routes_architect_stream_pipeline.cpp" \
  "$CPP_SRC/coordinator_routes_architect_stream_router.cpp" \
  "$CPP_SRC/coordinator_routes_architect_synthesis.cpp" \
  "$CPP_SRC/coordinator_routes_architect_persist.cpp" \
  "$CPP_SRC/coordinator_routes_filters.cpp" \
  "$CPP_SRC/coordinator_routes_health_agents.cpp" \
  "$CPP_SRC/coordinator_routes_misc.cpp" \
  "$CPP_SRC/coordinator_kv_ops.cpp" \
  "$CPP_SRC/coordinator_routes_cache.cpp" \
  "$CPP_SRC/coordinator_routes_modes.cpp" \
  "$CPP_SRC/coordinator_routes_modes_put.cpp" \
  "$CPP_SRC/coordinator_routes_presets.cpp" \
  "$CPP_SRC/coordinator_routes_rag_health.cpp" \
  "$CPP_SRC/swarm_config_store.cpp" "$CPP_SRC/swarm_config_roster.cpp" \
  "$CPP_SRC/agent_client.cpp" "$CPP_SRC/agent_client_http.cpp" \
  "$CPP_SRC/inference_backend.cpp" "$CPP_SRC/inference_backend_http.cpp" \
  "$CPP_SRC/backend_router.cpp" "$CPP_SRC/agent_client_pool.cpp" \
  "$CPP_SRC/agent_health.cpp" "$CPP_SRC/agent_metrics.cpp" \
  "$CPP_SRC/agent_stream.cpp" "$CPP_SRC/agent_stream_pool.cpp" \
  "$CPP_SRC/agent_stream_sse.cpp" \
  "$CPP_SRC/pressure_snapshot.cpp" "$CPP_SRC/pressure_snapshot_llama.cpp" \
  "$CPP_SRC/pressure_snapshot_mlx.cpp" "$CPP_SRC/host_memory.cpp" \
  "$CPP_SRC/pressure.cpp" "$CPP_SRC/pressure_evict.cpp" \
  "$CPP_SRC/pressure_evict_score.cpp" "$CPP_SRC/response_cache.cpp" \
  "$CPP_SRC/mlx_inflight.cpp" "$CPP_SRC/kv_router.cpp" \
  "$CPP_SRC/code_fence_normalize.cpp" \
  "$CPP_SRC/rag_config.cpp" "$CPP_SRC/rag_embed.cpp" \
  "$CPP_SRC/rag_client.cpp" "$CPP_SRC/rag_client_http.cpp" \
  "$ROOT/build/blake2b.o" \
  -I"$CPP_SRC" "${MOD_LINK[@]}" "${PROM_LINK[@]}" "${PQ_LINK[@]}" -pthread
echo "built $ROOT/bin/cofiswarm-coordinator"
