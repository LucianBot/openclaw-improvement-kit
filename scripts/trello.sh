#!/bin/bash
# Trello CLI Helper for Auderon HQ
# Usage: ./trello.sh <command> [args]

set -e

# Config from TOOLS.md
TRELLO_API_KEY="${TRELLO_API_KEY:-c668d7077112474a860bcecee5903411}"
TRELLO_TOKEN="${TRELLO_TOKEN:-ATTA82b5cb6431748b29ff823b10a9b7d7277226536e7978b64bc185ef2c939601540B1A8F2C}"
BOARD_ID="${TRELLO_BOARD_ID:-6980312cade1076e658f6266}"

# List IDs
LIST_INBOX="69803134f54cdfea885e8cde"
LIST_THIS_WEEK="69803134d4ff40c8cbfb43b8"
LIST_BACKLOG="6980313431d8336fc30d1538"
LIST_IN_PROGRESS="69803133c1ce60b503438d12"
LIST_DONE="69803133ffa0037ddcaf2807"

API_BASE="https://api.trello.com/1"
AUTH="key=$TRELLO_API_KEY&token=$TRELLO_TOKEN"

show_help() {
    cat << 'EOF'
Trello CLI Helper for Auderon HQ

USAGE:
    ./trello.sh <command> [arguments]

COMMANDS:
    lists                    List all lists on the board
    cards [list-name]        List cards (optionally filter by list: inbox, week, backlog, progress, done)
    add <title> [list]       Add a card (default: inbox). Lists: inbox, week, backlog, progress
    move <card-id> <list>    Move card to a list
    done <card-id>           Move card to Done
    comment <card-id> <msg>  Add a comment to a card
    archive <card-id>        Archive a card
    search <query>           Search cards on the board
    status                   Show board summary (card counts per list)

EXAMPLES:
    ./trello.sh add "Fix login bug" progress
    ./trello.sh cards week
    ./trello.sh done 6980xxxx
    ./trello.sh status
EOF
}

get_list_id() {
    case "$1" in
        inbox)    echo "$LIST_INBOX" ;;
        week)     echo "$LIST_THIS_WEEK" ;;
        backlog)  echo "$LIST_BACKLOG" ;;
        progress) echo "$LIST_IN_PROGRESS" ;;
        done)     echo "$LIST_DONE" ;;
        *)        echo "" ;;
    esac
}

cmd_lists() {
    curl -s "$API_BASE/boards/$BOARD_ID/lists?$AUTH" | jq -r '.[] | "\(.name): \(.id)"'
}

cmd_cards() {
    local list_filter="$1"
    local url="$API_BASE/boards/$BOARD_ID/cards?$AUTH"
    
    if [[ -n "$list_filter" ]]; then
        local list_id=$(get_list_id "$list_filter")
        if [[ -z "$list_id" ]]; then
            echo "Unknown list: $list_filter. Use: inbox, week, backlog, progress, done"
            exit 1
        fi
        url="$API_BASE/lists/$list_id/cards?$AUTH"
    fi
    
    curl -s "$url" | jq -r '.[] | "[\(.id | .[:8])] \(.name)"'
}

cmd_add() {
    local title="$1"
    local list="${2:-inbox}"
    
    if [[ -z "$title" ]]; then
        echo "Usage: ./trello.sh add <title> [list]"
        exit 1
    fi
    
    local list_id=$(get_list_id "$list")
    if [[ -z "$list_id" ]]; then
        echo "Unknown list: $list. Use: inbox, week, backlog, progress"
        exit 1
    fi
    
    local result=$(curl -s -X POST "$API_BASE/cards?$AUTH" \
        -d "idList=$list_id" \
        --data-urlencode "name=$title")
    
    local card_id=$(echo "$result" | jq -r '.id')
    local short_url=$(echo "$result" | jq -r '.shortUrl')
    
    echo "✅ Created: $title"
    echo "   ID: $card_id"
    echo "   URL: $short_url"
}

cmd_move() {
    local card_id="$1"
    local list="$2"
    
    if [[ -z "$card_id" || -z "$list" ]]; then
        echo "Usage: ./trello.sh move <card-id> <list>"
        exit 1
    fi
    
    local list_id=$(get_list_id "$list")
    if [[ -z "$list_id" ]]; then
        echo "Unknown list: $list. Use: inbox, week, backlog, progress, done"
        exit 1
    fi
    
    curl -s -X PUT "$API_BASE/cards/$card_id?$AUTH" -d "idList=$list_id" > /dev/null
    echo "✅ Moved card to $list"
}

cmd_done() {
    local card_id="$1"
    if [[ -z "$card_id" ]]; then
        echo "Usage: ./trello.sh done <card-id>"
        exit 1
    fi
    cmd_move "$card_id" "done"
}

cmd_comment() {
    local card_id="$1"
    shift
    local message="$*"
    
    if [[ -z "$card_id" || -z "$message" ]]; then
        echo "Usage: ./trello.sh comment <card-id> <message>"
        exit 1
    fi
    
    curl -s -X POST "$API_BASE/cards/$card_id/actions/comments?$AUTH" \
        --data-urlencode "text=$message" > /dev/null
    echo "✅ Comment added"
}

cmd_archive() {
    local card_id="$1"
    if [[ -z "$card_id" ]]; then
        echo "Usage: ./trello.sh archive <card-id>"
        exit 1
    fi
    
    curl -s -X PUT "$API_BASE/cards/$card_id?$AUTH" -d "closed=true" > /dev/null
    echo "✅ Card archived"
}

cmd_search() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: ./trello.sh search <query>"
        exit 1
    fi
    
    curl -s "$API_BASE/search?$AUTH&query=$query&idBoards=$BOARD_ID&modelTypes=cards" | \
        jq -r '.cards[] | "[\(.id | .[:8])] \(.name)"'
}

cmd_status() {
    echo "📊 Auderon HQ Board Status"
    echo "=========================="
    
    local lists=$(curl -s "$API_BASE/boards/$BOARD_ID/lists?$AUTH&cards=all")
    
    echo "$lists" | jq -r '.[] | "\(.name): \(.cards | length) cards"'
    
    echo ""
    echo "🔄 In Progress:"
    echo "$lists" | jq -r '.[] | select(.name | contains("Progress")) | .cards[] | "  • \(.name)"'
}

# Main dispatch
case "${1:-help}" in
    lists)   cmd_lists ;;
    cards)   cmd_cards "$2" ;;
    add)     shift; cmd_add "$@" ;;
    move)    cmd_move "$2" "$3" ;;
    done)    cmd_done "$2" ;;
    comment) shift; cmd_comment "$@" ;;
    archive) cmd_archive "$2" ;;
    search)  cmd_search "$2" ;;
    status)  cmd_status ;;
    help|-h|--help) show_help ;;
    *)       echo "Unknown command: $1"; show_help; exit 1 ;;
esac
