# Publish to github-pages
ghp-publish() {
  local cur_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  git checkout master && \
    git pull && \
    git checkout gh-pages && \
    git pull && \
    git merge master --no-edit && \
    git push && \
    git checkout $cur_branch
}

# Get rid of already-merged branches
# http://stackoverflow.com/questions/17983068/git-delete-local-branches-after-deleting-them-on-remote
git-clean-branches() {
    git branch --merged | \
    grep -v "\*" | \
    grep -v "master" | \
    grep -v "develop" | \
    xargs -n 1 git branch -d
}

# Get rid of .orig files from merge conflicts
git-clean-orig() {
    git status -su | grep -e"\.orig$" | cut -f2 -d" " | xargs rm -r
}

# Update the .gitignore with all currently untracked files
git-update-gitignore() {
  touch .gitignore
  git status --porcelain | grep '^??' | cut -c4- >> .gitignore
}
