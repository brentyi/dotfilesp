# partially plagiarized from sunaku

# set color based on hash of machine hostname

if [ -z "$user_color" ]; then
    user_color=$(( 0x${$(md5sum <<< $HOST):0:10} % 6 + 1 ))
fi
if [ -n "$SSH_CONNECTION" ]; then
    if [ -n "$RPS1" ]; then
        # decoupling workaround
        RPROMPT=$RPS1
    fi
    if [[ ! $RPROMPT =~ '$(ssh_indicator)' ]]; then
        RPROMPT=$RPROMPT'$(ssh_indicator)'
    fi
fi
# red if root
test $UID -eq 0 && user_color='red'

function ssh_indicator() {
    test -n "$SSH_CONNECTION" && echo "%K{$user_color} $USER@$HOST %k"
}

PROMPT='%(?..%{$fg_bold[red]%}exit %?
%{$reset_color%})'\
'%{$bold_color%}$(git_prompt_status)%{$reset_color%}'\
'$(git_prompt_info)'\
'%F{$user_color}%~%f'\
'%(!.#.>) '
PROMPT2='%{$fg[red]%}\ m %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[magenta]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}?"

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
