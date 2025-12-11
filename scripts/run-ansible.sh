#!/bin/bash
# Ansible runner script for local execution
# Usage: ./run-ansible.sh [playbook] [target] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
PLAYBOOK="${1:-sonarqube.yml}"
TARGET="${2:-all}"
DRY_RUN=false
VERBOSE=""

# Parse options
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --check|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|-vv|-vvv)
            VERBOSE="$1"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Ansible Playbook Runner${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Playbook: ${YELLOW}$PLAYBOOK${NC}"
echo -e "Target:   ${YELLOW}$TARGET${NC}"
echo -e "Dry Run:  ${YELLOW}$DRY_RUN${NC}"
echo ""

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: ansible-playbook not found. Install with: brew install ansible${NC}"
    exit 1
fi

# Check if playbook exists
if [[ ! -f "$ANSIBLE_DIR/playbooks/$PLAYBOOK" ]]; then
    echo -e "${RED}Error: Playbook '$PLAYBOOK' not found in $ANSIBLE_DIR/playbooks/${NC}"
    echo ""
    echo "Available playbooks:"
    ls -1 "$ANSIBLE_DIR/playbooks/"
    exit 1
fi

# Build command
CMD="ansible-playbook"
CMD="$CMD -i $ANSIBLE_DIR/inventory/hosts.yml"
CMD="$CMD $ANSIBLE_DIR/playbooks/$PLAYBOOK"
CMD="$CMD --limit $TARGET"

if [[ "$DRY_RUN" == "true" ]]; then
    CMD="$CMD --check --diff"
fi

if [[ -n "$VERBOSE" ]]; then
    CMD="$CMD $VERBOSE"
fi

echo -e "${YELLOW}Running: $CMD${NC}"
echo ""

# Execute
cd "$ANSIBLE_DIR"
$CMD

echo ""
echo -e "${GREEN}✅ Playbook completed successfully!${NC}"
