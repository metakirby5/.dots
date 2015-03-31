# Prompt functions
if not set -q -g __fish_mk5_prompt_functions_defined
  set -g __fish_mk5_prompt_functions_defined

  function __fish_mk5_git_pwd
    # Get git base directory
    set -l gitbase (git rev-parse --show-toplevel ^/dev/null)
    if [ $gitbase ]
      # Format for sed
      set -l sed_gitbase (echo $gitbase | sed 's/\//\\\\\//g')
      # Strip git base directory
      echo -s (basename $gitbase) (pwd | sed "s/$sed_gitbase//g")
    else
      # Replace home with ~
      if [ $USER = 'root' ]
        echo (pwd) | sed "s/^\/root/~/"
      else
        echo (pwd) | sed "s/^\/home\/$USER/~/"
      end
    end
  end

  function __fish_mk5_git_branch_name
    echo (git rev-parse --abbrev-ref HEAD ^/dev/null)
  end

  function __fish_mk5_git_is_dirty
    echo (git status -s --ignore-submodules=dirty ^/dev/null)
  end

end

function fish_prompt
  # Grab status code first
  set -l last_status $status

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

  echo -n -s (set_color green) (__fish_mk5_git_pwd) ' ' \
             $chevcolor $chev (set_color normal) ' '
end

function fish_right_prompt
  set -l yellow (set_color -o yellow)
  set -l gray (set_color -o 555)
  set -l normal (set_color normal)

  if [ (__fish_mk5_git_branch_name) ]
    set git_info $gray(__fish_mk5_git_branch_name)

    if [ (__fish_mk5_git_is_dirty) ]
      set -l dirty "$yellow✗"
      set git_info "$dirty $git_info"
    end
  end

  echo -n -s $git_info $normal
end
