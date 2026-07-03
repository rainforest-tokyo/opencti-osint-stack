#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-all}"

usage() {
  cat <<'USAGE'
Usage: ./scripts/down.sh <command>

Commands:
  all       Stop all services across all profiles without deleting volumes
  default   Stop default-profile services only without deleting volumes
  clean     Stop all profile services and remove any remaining xtm-* containers
  stop      Stop all profile services without removing containers
  help      Show this help
USAGE
}

profiles=(--profile internal --profile default-data --profile no-key --profile api-key --profile senda --profile xtm)

case "$cmd" in
  all)
    docker compose "${profiles[@]}" down
    ;;
  default)
    docker compose down
    ;;
  clean)
    docker compose "${profiles[@]}" down
    docker ps -a --format '{{.Names}}' | grep '^xtm-' | xargs -r docker rm -f
    ;;
  stop)
    docker compose "${profiles[@]}" stop
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
