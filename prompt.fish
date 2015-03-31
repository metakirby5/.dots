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
  set branch (git symbolic-ref HEAD ^/dev/null)

  if [ $status = 0 ]
    echo $branch | sed "s|^refs/heads/||"
  else # detached head
    echo (git rev-parse --short HEAD ^/dev/null)
  end
end

function __mk5_git_dirty
  echo (git status -s --ignore-submodules=dirty ^/dev/null)
end

function __mk5_git_outgoing
  echo (git log @{u}.. ^/dev/null)
end

function __mk5_git_incoming
  echo (git log ..@{u} ^/dev/null)
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
    set chev '❱❱❱'
  else
    set chev '❱'
  end

  echo -n -s (set_color green) (__mk5_git_pwd) ' ' \
             $chevcolor $chev (set_color normal) ' '
end

function fish_right_prompt
  set gray (set_color -o 555)
  set yellow (set_color -o yellow)
  set red (set_color -o red)
  set blue (set_color -o blue)
  set normal (set_color normal)

  if [ (__mk5_git_branch) ]
    set git_info "$gray"(__mk5_git_branch)

    if [ (__mk5_git_dirty) ]
      set git_info "$yellow± $git_info"
    end

    if [ (__mk5_git_incoming) ]
      set git_info "$red⬇ $git_info"
    end

    if [ (__mk5_git_outgoing) ]
      set git_info "$blue⬆ $git_info"
    end
  end

  echo -n -s $git_info $normal
end
