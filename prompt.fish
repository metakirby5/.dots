set -g __mk5_hostname (hostname|cut -d . -f 1)

function __mk5_git_pwd
  # Get git base directory
  set gitbase (git rev-parse --show-toplevel ^/dev/null)

  if [ $gitbase ]
    # Strip git base directory
    echo -s (basename $gitbase) (pwd | sed "s|^$gitbase||")
  else
    # Replace home with ~
    echo (pwd) | sed "s|^$HOME|~|"
  end
end

function __mk5_git_branch
  echo (git symbolic-ref HEAD ^/dev/null
  or git rev-parse --short HEAD ^/dev/null) \
  | sed "s|^refs/heads/||"
end

function __mk5_git_dirty
  echo (git status -s --ignore-submodules=dirty ^/dev/null | wc -l)
end

function __mk5_git_outgoing
  echo (git log origin/HEAD.. ^/dev/null | grep '^commit' | wc -l)
end

function __mk5_git_incoming
  echo (git log ..origin/HEAD ^/dev/null | grep '^commit' | wc -l)
end

function fish_prompt
  # Grab status code first
  set last_status $status

  if [ $last_status = 0 ]
    set chevcolor (set_color -o green)
  else
    set chevcolor (set_color -o red)
  end

  if [ $USER = 'root' ]
    set chev '❯❯❯'
  else
    set chev '❯'
  end

  echo -n -s \
    (set_color cyan) "$USER@$__mk5_hostname" \
    (set_color -o cyan) ' ❯ ' (set_color normal) \
    (set_color green) (__mk5_git_pwd) ' ' \
    $chevcolor $chev (set_color normal) ' '
end

function fish_right_prompt

  if [ (__mk5_git_branch) ]
    set git_info (set_color -o 555) (__mk5_git_branch)

    if [ (__mk5_git_dirty) != 0 ]
      set git_info (set_color -o yellow) '±' (__mk5_git_dirty) ' ' $git_info
    end

    if [ (__mk5_git_incoming) != 0 ]
      set git_info (set_color -o red) '⬇' (__mk5_git_incoming) ' ' $git_info
    end

    if [ (__mk5_git_outgoing) != 0 ]
      set git_info (set_color -o blue) '⬆' (__mk5_git_outgoing) ' ' $git_info
    end
  end

  echo -n -s $git_info (set_color normal)
end
