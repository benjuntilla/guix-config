#!/usr/bin/env zsh

# Define the check_git_status function
check_git_status() {
    local git_repo_path=$1
    cd $git_repo_path

    local status_text=""
    local is_clean=true
    local is_up_to_date=true

    if ! git diff-index --quiet HEAD --; then
        status_text+="$git_repo_path is not clean. "
        is_clean=false
    fi

    git fetch

    local LOCAL=$(git rev-parse @)
    local REMOTE=$(git rev-parse @{u})
    local BASE=$(git merge-base @ @{u})

    if [ $LOCAL = $REMOTE ]; then
        :
        # status_text+="$git_repo_path is up to date. "
    elif [ $LOCAL = $BASE ]; then
        status_text+="$git_repo_path needs to pull. "
        is_up_to_date=false
    else
        status_text+="$git_repo_path has diverged. "
        is_up_to_date=false
    fi

    echo "{\"status_text\": \"$status_text\", \"is_clean\": $is_clean, \"is_up_to_date\": $is_up_to_date}"
}

# List of Git repository paths
git_repos=(
    "/home/ben/src/resume"
    "/home/ben/src/guix-config"
    "/home/ben/.password-store"
)

# Variables to store final status
final_status_text=""
all_clean=true
all_up_to_date=true

# Iterate through the repositories
for repo_path in "${git_repos[@]}"; do
    repo_status=$(check_git_status "$repo_path")
    status_text=$(echo $repo_status | jq -r '.status_text')
    is_clean=$(echo $repo_status | jq -r '.is_clean')
    is_up_to_date=$(echo $repo_status | jq -r '.is_up_to_date')

    final_status_text+="$status_text"

    if [ "$is_clean" = "false" ] || [ "$is_up_to_date" = "false" ]; then
        all_clean=false
    fi
done

# Set the class based on the overall cleanliness and update status
if [ "$all_clean" = "true" ]; then
    class="clean"
    emoji="🟢"
else
    class="not-clean"
    emoji="🟡"
fi
# Output final JSON result
echo "{\"text\": \"$emoji\", \"class\": \"$class\", \"tooltip\": \"$final_status_text\"}" | jq --unbuffered --compact-output
