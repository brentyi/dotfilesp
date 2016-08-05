# partially plagiarized from sunaku

# set color to cyan by default
local user_color='cyan'
# green if ssh
if [ -n "$SSH_CONNECTION" ]; then
    user_color='green'
    if [[ ! $RPROMPT =~ '$(ssh_indicator)' ]]; then
        RPROMPT=$RPROMPT'$(ssh_indicator)'
    fi
fi
# red if root
test $UID -eq 0 && user_color='red'

function ssh_indicator() {
    test -n "$SSH_CONNECTION" && echo "%K{cyan} $USER@$HOST %k"
}

PROMPT='%(?..%{$fg_bold[red]%}exit %?
%{$reset_color%})'\
'%{$bold_color%}$(git_prompt_status)%{$reset_color%}'\
'$(git_prompt_info)'\
'%{$fg[$user_color]%}%~%{$reset_color%}'\
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
