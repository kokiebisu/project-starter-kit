# Enables a tmux workspace with 3 panes. Suitable for local development
# You can pass a container ID to the workspace command to attach to a running container or 
# run the command from the working directory of the container to attach to it.
create_workspace() {
  local container_id="$1"

  # Check if container is running when container_id is provided
  if [[ -n "$container_id" ]]; then
    if ! docker ps --format '{{.ID}}' | grep -q "^${container_id}"; then
      echo "Error: Container ${container_id} is not running"
      return 1
    fi 
  fi
 
  local current_dir=$(basename "$PWD")
  container_id=$(docker ps --format '{{.ID}}\t{{.Names}}' | awk -v dir="$current_dir" '$2 ~ dir {print $1}' | head -n1)

  if [[ -z "$container_id" ]]; then
    echo "Error: No running container found matching directory name: ${current_dir}"
    return 1
  fi

  local container_name=$(docker ps --format '{{.Names}}' --filter "id=$container_id")
  local workspace_path="/workspaces/${container_name}"

  # Detect shell and use appropriate one
  local shell_path="/usr/bin/bash"
  if command -v zsh &> /dev/null; then
    shell_path="/usr/bin/zsh"
  fi

  # Enter the container and create tmux session from within
  docker exec -it "$container_id" $shell_path -c "
    export LANG=ja_JP.UTF-8 &&
    cd ${workspace_path} &&
    tmux new-session -d -s workspace '$shell_path' && \
    tmux set-option -g default-shell $shell_path && \
    tmux set-option -g mouse on && \
    tmux split-window -v '$shell_path' && \
    tmux split-window -h '$shell_path' && \
    tmux select-pane -t 0 && \
    tmux attach-session -t workspace
  "
}

alias workspace="create_workspace"
alias killmux="tmux kill-session -a"
