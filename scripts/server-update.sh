#!/bin/bash
# Server Update CLI Tool
# Usage: ./server-update.sh [command] [options]

set -e

REPO="ErnestoCobos/Infra"
WORKFLOW="server-updates.yml"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}Server Update CLI Tool${NC}"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  smart [target]        Check updates, apply only if NO reboot needed (default)"
    echo "  check [target]        Only check what updates are available"
    echo "  apply [target]        Apply updates without reboot"
    echo "  apply-reboot [target] Apply updates AND reboot if needed"
    echo "  status                Show status of last run"
    echo "  logs                  Download logs from last run"
    echo "  logs [run_id]         Download logs from specific run"
    echo "  watch                 Watch current run progress"
    echo "  list                  List recent runs"
    echo ""
    echo "Modes explained:"
    echo "  smart       → Check first. If reboot needed: report only. If no reboot: apply."
    echo "  check       → Only check what updates are available (no changes)"
    echo "  apply       → Apply all updates but do NOT reboot"
    echo "  apply-reboot→ Apply all updates AND reboot if kernel updated"
    echo ""
    echo "Examples:"
    echo "  $0 smart                    # Smart mode on all servers (default)"
    echo "  $0 check sonarqube          # Just check a specific server"
    echo "  $0 apply all                # Apply updates, no reboot"
    echo "  $0 apply-reboot sonarqube   # Apply with reboot if needed"
    echo "  $0 logs                     # Download last run logs"
}

check_gh() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) not found${NC}"
        echo "Install with: brew install gh"
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Error: Not authenticated with GitHub CLI${NC}"
        echo "Run: gh auth login"
        exit 1
    fi
}

run_update() {
    local target="${1:-all}"
    local mode="${2:-smart}"

    echo -e "${YELLOW}🚀 Triggering server update...${NC}"
    echo -e "   Target: ${BLUE}$target${NC}"
    echo -e "   Mode:   ${BLUE}$mode${NC}"
    echo ""

    gh workflow run "$WORKFLOW" \
        --repo "$REPO" \
        -f target="$target" \
        -f mode="$mode"

    echo -e "${GREEN}✅ Workflow triggered!${NC}"
    echo ""
    echo "Watch progress with:"
    echo "  $0 watch"
    echo ""
    echo "Or view in browser:"
    gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 1 --json url --jq '.[0].url'
}

get_status() {
    echo -e "${BLUE}📊 Last run status:${NC}"
    echo ""
    gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 5 \
        --json databaseId,status,conclusion,createdAt,headBranch \
        --jq '.[] | "  \(.databaseId) | \(.status) | \(.conclusion // "running") | \(.createdAt)"'
}

download_logs() {
    local run_id="$1"
    local download_dir="./logs/downloads"

    mkdir -p "$download_dir"

    if [ -z "$run_id" ]; then
        echo -e "${YELLOW}📥 Downloading logs from last run...${NC}"
        run_id=$(gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 1 --json databaseId --jq '.[0].databaseId')
    fi

    echo -e "   Run ID: ${BLUE}$run_id${NC}"

    gh run download "$run_id" --repo "$REPO" --dir "$download_dir/$run_id"

    echo -e "${GREEN}✅ Logs downloaded to: $download_dir/$run_id${NC}"
    echo ""
    echo "Log files:"
    ls -la "$download_dir/$run_id"/*/ 2>/dev/null || ls -la "$download_dir/$run_id"
}

watch_run() {
    echo -e "${YELLOW}👀 Watching latest run...${NC}"
    local run_id=$(gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 1 --json databaseId --jq '.[0].databaseId')
    gh run watch "$run_id" --repo "$REPO"
}

list_runs() {
    echo -e "${BLUE}📋 Recent runs:${NC}"
    echo ""
    gh run list --repo "$REPO" --workflow "$WORKFLOW" --limit 10
}

# Main
check_gh

case "${1:-help}" in
    smart)
        run_update "${2:-all}" "smart"
        ;;
    check)
        run_update "${2:-all}" "check"
        ;;
    apply)
        run_update "${2:-all}" "apply"
        ;;
    apply-reboot)
        run_update "${2:-all}" "apply-reboot"
        ;;
    status)
        get_status
        ;;
    logs)
        download_logs "$2"
        ;;
    watch)
        watch_run
        ;;
    list)
        list_runs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
