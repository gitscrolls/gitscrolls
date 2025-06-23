#!/bin/bash

# Script to toggle between normal and verbose git hooks

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

HOOKS_DIR=".git/hooks"

toggle_hook() {
    local hook_name="$1"
    local current_hook="$HOOKS_DIR/$hook_name"
    local verbose_hook="$HOOKS_DIR/$hook_name-verbose"
    local normal_hook="$HOOKS_DIR/$hook_name-normal"
    
    if [ ! -f "$current_hook" ]; then
        echo -e "${YELLOW}No $hook_name hook found${NC}"
        return
    fi
    
    # Check if hook is currently verbose
    if grep -q "set -x" "$current_hook" 2>/dev/null; then
        # Currently verbose, switch to normal
        if [ -f "$normal_hook" ]; then
            cp "$normal_hook" "$current_hook"
            echo -e "${GREEN}✅ $hook_name switched to normal mode${NC}"
        else
            # Backup current verbose as normal isn't available
            echo -e "${YELLOW}No normal version found. Current hook remains verbose.${NC}"
        fi
    else
        # Currently normal, switch to verbose
        if [ ! -f "$normal_hook" ]; then
            # Backup current normal version
            cp "$current_hook" "$normal_hook"
        fi
        
        if [ -f "$verbose_hook" ]; then
            cp "$verbose_hook" "$current_hook"
            echo -e "${GREEN}✅ $hook_name switched to verbose mode${NC}"
        else
            echo -e "${YELLOW}No verbose version found for $hook_name${NC}"
        fi
    fi
}

# Parse command line arguments
case "$1" in
    verbose|v)
        echo -e "${BLUE}🔧 Enabling verbose mode for git hooks...${NC}"
        
        # Backup current hooks if they're not verbose
        for hook in pre-commit pre-push; do
            if [ -f "$HOOKS_DIR/$hook" ] && ! grep -q "set -x" "$HOOKS_DIR/$hook"; then
                cp "$HOOKS_DIR/$hook" "$HOOKS_DIR/$hook-normal"
            fi
            
            # Switch to verbose
            if [ -f "$HOOKS_DIR/$hook-verbose" ]; then
                cp "$HOOKS_DIR/$hook-verbose" "$HOOKS_DIR/$hook"
                echo -e "${GREEN}✅ $hook switched to verbose mode${NC}"
            fi
        done
        ;;
        
    normal|n)
        echo -e "${BLUE}🔧 Enabling normal mode for git hooks...${NC}"
        
        for hook in pre-commit pre-push; do
            if [ -f "$HOOKS_DIR/$hook-normal" ]; then
                cp "$HOOKS_DIR/$hook-normal" "$HOOKS_DIR/$hook"
                echo -e "${GREEN}✅ $hook switched to normal mode${NC}"
            elif [ -f "$HOOKS_DIR/$hook" ] && grep -q "set -x" "$HOOKS_DIR/$hook"; then
                echo -e "${YELLOW}⚠️  No normal version of $hook found${NC}"
            fi
        done
        ;;
        
    toggle|t)
        echo -e "${BLUE}🔧 Toggling git hooks mode...${NC}"
        toggle_hook "pre-commit"
        toggle_hook "pre-push"
        ;;
        
    status|s)
        echo -e "${BLUE}📊 Git hooks status:${NC}"
        for hook in pre-commit pre-push; do
            if [ -f "$HOOKS_DIR/$hook" ]; then
                if grep -q "set -x" "$HOOKS_DIR/$hook"; then
                    echo -e "  $hook: ${YELLOW}verbose${NC}"
                else
                    echo -e "  $hook: ${GREEN}normal${NC}"
                fi
            else
                echo -e "  $hook: ${YELLOW}not installed${NC}"
            fi
        done
        ;;
        
    *)
        echo "Usage: $0 {verbose|v|normal|n|toggle|t|status|s}"
        echo ""
        echo "Commands:"
        echo "  verbose, v  - Enable verbose mode (shows all commands)"
        echo "  normal, n   - Enable normal mode (quiet output)"
        echo "  toggle, t   - Toggle between verbose and normal"
        echo "  status, s   - Show current hook modes"
        exit 1
        ;;
esac