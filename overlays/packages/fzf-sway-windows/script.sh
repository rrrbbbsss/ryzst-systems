# shellcheck shell=bash

# shellcheck disable=SC2016
WINDOW_QUERY='
.nodes[].nodes[]
| . as $workspace
| recurse(.nodes[]?)
| recurse(.floating_nodes[]?)
| select(.app_id != null)
| [{ workspace: { name: $workspace.name },
     window: { name: .name, app: .app_id, id: .id }}]
'
WINDOW_DATA=$(swaymsg -t get_tree | jq "$WINDOW_QUERY")

ITEMS_QUERY='
.[] | .window.id, " [", .window.app, "] ", .window.name, " (", .workspace.name, ")\n"
'
ITEMS_DATA=$(jq -j "$ITEMS_QUERY" <<<"$WINDOW_DATA")

SELECTION=$(fzf --reverse --with-nth 2.. --prompt='Windows > ' <<<"$ITEMS_DATA")
SELECTION_ID=$(cut -d " " -f 1 <<<"$SELECTION")
swaymsg "[con_id=$SELECTION_ID]" focus
