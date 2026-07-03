#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-help}"

usage() {
  cat <<'USAGE'
Usage: ./scripts/start.sh <command>

Commands:
  base            Start OpenCTI core only
  internal        Start internal import/export/analysis connectors
  default-data    Start OpenCTI Datasets and MITRE connectors
  no-key          Start no-key OSINT connectors
  api-key         Start API-key OSINT connectors
  senda           Start Senda-Nexus connectors
  xtm             Start XTM One / XTM Composer components
  all             Start every profile: base, internal, default-data, no-key, api-key, senda, xtm
  all-safe        Start base -> internal -> default-data -> no-key
  all-osint       Start base -> internal -> default-data -> no-key -> api-key
  status          Show active containers
  status-all      Show all profile containers, including stopped ones
  logs-senda      Follow Senda connector logs
  logs-osint      Follow OSINT connector logs
  down            Stop default-profile services without deleting volumes
  down-all        Stop all services across all profiles without deleting volumes
  stop-xtm        Stop any running xtm-* containers, useful before host shutdown
USAGE
}

need_env() {
  if [ ! -f .env ]; then
    echo "Missing .env. Copy .env.sample to .env and replace CHANGE_ME values." >&2
    exit 1
  fi
}

case "$cmd" in
  base)
    need_env
    docker compose up -d
    ;;
  internal)
    need_env
    docker compose --profile internal up -d
    ;;
  default-data)
    need_env
    docker compose --profile default-data up -d connector-opencti
    docker compose --profile default-data up -d connector-mitre
    ;;
  no-key)
    need_env
    docker compose --profile no-key up -d
    ;;
  api-key)
    need_env
    docker compose --profile api-key up -d
    ;;
  senda)
    need_env
    docker compose --profile senda up -d
    ;;
  xtm)
    need_env
    docker compose --profile xtm up -d
    ;;
  all)
    need_env
    docker compose up -d
    docker compose --profile internal up -d
    docker compose --profile default-data up -d connector-opencti
    docker compose --profile default-data up -d connector-mitre
    docker compose --profile no-key up -d
    docker compose --profile api-key up -d
    docker compose --profile senda up -d
    docker compose --profile xtm up -d
    ;;
  all-safe)
    need_env
    docker compose up -d
    docker compose --profile internal up -d
    docker compose --profile default-data up -d connector-opencti
    docker compose --profile default-data up -d connector-mitre
    docker compose --profile no-key up -d
    ;;
  all-osint)
    need_env
    docker compose up -d
    docker compose --profile internal up -d
    docker compose --profile default-data up -d connector-opencti
    docker compose --profile default-data up -d connector-mitre
    docker compose --profile no-key up -d
    docker compose --profile api-key up -d
    ;;
  status)
    docker compose ps
    ;;
  status-all)
    docker compose --profile internal --profile default-data --profile no-key --profile api-key --profile senda --profile xtm ps -a
    ;;
  logs-senda)
    docker compose logs --tail=100 -f senda-nexus-feed senda-nexus-enrichment senda-nexus-enrichment-live
    ;;
  logs-osint)
    docker compose logs --tail=100 -f connector-cisa-known-exploited-vulnerabilities connector-first-epss-bulk connector-cvelistv5 connector-shodan-internetdb connector-abuseipdb-ipblacklist connector-malwarebazaar-recent-additions connector-urlhaus-recent-payloads connector-alienvault
    ;;
  down)
    docker compose down
    ;;
  down-all)
    docker compose --profile internal --profile default-data --profile no-key --profile api-key --profile senda --profile xtm down
    ;;
  stop-xtm)
    docker ps --format '{{.Names}}' | grep '^xtm-' | xargs -r docker stop
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
