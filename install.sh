#!/usr/bin/env bash

# @file install.sh
# @brief install script for all configuration


# @description check if the user is root then execute the command
#
# @arg $1 a bash command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
exec_root() {
    local command="$*"
    if [[ ! "$#" -eq 0 ]]; then
        if [[ "$UID" -gt 0 ]]; then
            echo "sudo $command"
            sudo $command
        else
            echo "$command"
            $command
        fi
        return 0
    fi
    return 1
}



# @description show aliases in the current shell
# Detect Operating System
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
dist_check() {
    DIST_CHECK="/etc/os-release"
    if [ -e $DIST_CHECK ]; then
        source $DIST_CHECK
        DISTRO=$ID
        VERSION=$VERSION_ID
        export DISTRO
        export VERSION
    else
        echo "Your distribution is not supported (yet)."
        exit
    fi
}


# @description install package
#
# @args $@ packages to install
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_package(){
    echo "apt install $@"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        for var in "$@"; do
            exec_root "apt-get -qq install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        for var in "$@"; do
            exec_root "pacman -Syu --noconfirm $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        for var in "$@"; do
            exec_root "dnf install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        for var in "$@"; do
            exec_root "yum install -y $var" >/dev/null
        done
        return 0
    fi
	if [ "$OSTYPE" == "Darwin" ]; then
        for var in "$@"; do
			brew install -q -y $var > /dev/null
        done
        return 0
    fi
    return 1
}


# @description Install The ultimate Vim configuration (vimrc) https://github.com/amix/vimrc
# @exitcode 0 If successfull and install vimrc
# @exitcode 1 On failure
install_vimrc() {
	echo "Install vimrc"

	install_package vim
	git clone -q --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime > /dev/null
	sh ~/.vim_runtime/install_awesome_vimrc.sh
	# check if the line exist then write it in .bashrc
	grep -qxF 'alias vi=vim' ~/.bashrc || echo 'alias vi=vim' >> ~/.bashrc
}

# @description Edit vimrc for my need
# @exitcode 0 If successfull and edit vimrc
# @exitcode 1 On failure
edit_vimrc(){
    echo "Modify vimrc"

    sed -i -e 's/let g:NERDTreeWinPos = "right"/let g:NERDTreeWinPos = "left"/g' ~/.vim_runtime/vimrcs/plugins_config.vim
    touch ~/.vim_runtime/vimrcs/my_configs.vim
    echo 'set number' > ~/.vim_runtime/vimrcs/my_configs.vim
}

# @description Install Oh my zsh
# @exitcode 0 If successfull and install oh my zsh
# @exitcode 1 On failure
install_oh_my_zsh(){
	echo "Install Oh my zsh"

    install_package zsh curl wget > /dev/null
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -q -O oh-my-zsh-install.sh
    sed -i -e 's/exec zsh -l//g' oh-my-zsh-install.sh
    bash oh-my-zsh-install.sh
    rm -f oh-my-zsh-install.sh
}

# @description Edit config Oh my zsh
# @exitcode 0 If successfull and edit with my custom config oh my zsh
# @exitcode 1 On failure
edit_oh_my_zsh(){
    echo "Install themes for oh-my-zsh"

    # powerline10k
    #git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
    #sed -i -e 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#g' ~/.zshrc
    #zsh -i -c "source ~/.zshrc && p10k configure"

    sed -i -e 's#ZSH_THEME="robbyrussell"#ZSH_THEME="lukeandrandall"#g' ~/.zshrc
    zsh -i -c "source ~/.zshrc"

	mkdir ~/.oh-my-zsh/custom/themes/minimal-theme
	cat > ~/.oh-my-zsh/custom/themes/minimal-theme/minimal-theme.zsh-theme << EOF
local return_code="%(?..%{$fg_bold[red]%}%? %{$reset_color%})"
function my_git_prompt_info() {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	GIT_STATUS=$(git_prompt_status)
  	[[ -n $GIT_STATUS ]] && GIT_STATUS=" $GIT_STATUS"
  	echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$GIT_STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%} %{$fg_bold[blue]%}%2~%{$reset_color%} $(my_git_prompt_info)%{$reset_color%}%B%b '
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=") %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"
EOF

	sed -i -e 's#ZSH_THEME="robbyrussell"#ZSH_THEME="minimal-theme/minimal-theme"#g' ~/.zshrc
	zsh -i -c "source ~/.zshrc"
}

# @description Install tmux
# @exitcode 0 If successfull and install tmux
# @exitcode 1 On failure
install_tmux(){
    echo "Install tmux"

    install_package tmux > /dev/null
    cat > ~/.tmux.conf << EOF
### -- Windows & Pane creation -- ###

# New Window retains current path, possible values are:
#   - true
#   - false (default)

tmux_conf_new_window_retain_current_path=false

# New Pane retains current path, possible values are:
#   - true (default)
#   - false

tmux_conf_new_pane_retain_current_path=true

# New Pane tries to reconnect ssh sessions (experimental), possible values are:
#   - true
#   - false (default)

tmux_conf_new_pane_reconnect_ssh=false

# Prompt for session name when creating a new session, possible values are:
#   - true
#   - false (default)

tmux_conf_new_session_prompt=false


### -- Display -- ###

# RGB 24-bit colour support (tmux >= 2.2), possible values are:
#  - true
#  - false (default)
tmux_conf_24b_colour=ture

# Default theme
tmux_conf_theme_colour_1="#080808"    # dark gray
tmux_conf_theme_colour_2="#303030"    # gray
tmux_conf_theme_colour_3="#8a8a8a"    # light gray
tmux_conf_theme_colour_4="#00afff"    # light blue
tmux_conf_theme_colour_5="#ffff00"    # yellow
tmux_conf_theme_colour_6="#080808"    # dark gray
tmux_conf_theme_colour_7="#e4e4e4"    # white
tmux_conf_theme_colour_8="#080808"    # dark gray
tmux_conf_theme_colour_9="#ffff00"    # yellow
tmux_conf_theme_colour_10="#ff00af"   # pink
tmux_conf_theme_colour_11="#5fff00"   # green
tmux_conf_theme_colour_12="#8a8a8a"   # light gray
tmux_conf_theme_colour_13="#e4e4e4"   # white
tmux_conf_theme_colour_14="#080808"   # dark gray
tmux_conf_theme_colour_15="#080808"   # dark gray
tmux_conf_theme_colour_16="#d70000"   # red
tmux_conf_theme_colour_17="#e4e4e4"   # white

# Default theme (ansi)
#tmux_conf_theme_colour_1="colour0"
#tmux_conf_theme_colour_2="colour8"
#tmux_conf_theme_colour_3="colour8"
#tmux_conf_theme_colour_4="colour14"
#tmux_conf_theme_colour_5="colour11"
#tmux_conf_theme_colour_6="colour0"
#tmux_conf_theme_colour_7="colour15"
#tmux_conf_theme_colour_8="colour0"
#tmux_conf_theme_colour_9="colour11"
#tmux_conf_theme_colour_10="colour13"
#tmux_conf_theme_colour_11="colour10"
#tmux_conf_theme_colour_12="colour8"
#tmux_conf_theme_colour_13="colour15"
#tmux_conf_theme_colour_14="colour0"
#tmux_conf_theme_colour_15="colour0"
#tmux_conf_theme_colour_16="colour1"
#tmux_conf_theme_colour_17="colour15"

# Window style
tmux_conf_theme_window_fg="default"
tmux_conf_theme_window_bg="default"

# Highlight focused pane (tmux >= 2.1), possible values are:
#   - true
#   - false (default)

tmux_conf_theme_highlight_focused_pane=false

# Focused pane colours:
tmux_conf_theme_focused_pane_bg="$tmux_conf_theme_colour_2"

# Pane border style, possible values are:
#   - thin (default)
#   - fat

tmux_conf_theme_pane_border_style=thin

# Pane borders colours:
tmux_conf_theme_pane_border="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"

# Pane indicator colours (when you hit <prefix> + q)
tmux_conf_theme_pane_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_pane_active_indicator="$tmux_conf_theme_colour_4"

# Status line style
tmux_conf_theme_message_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_attr="bold"

# Status line command style (<prefix> : Escape)
tmux_conf_theme_message_command_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_command_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_command_attr="bold"

# Window modes style
tmux_conf_theme_mode_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_mode_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_mode_attr="bold"

# Status line style
tmux_conf_theme_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_status_attr="none"

# Terminal title
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}

tmux_conf_theme_terminal_title="#h  #S  #I #W"

# Window status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}

tmux_conf_theme_window_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_attr="none"
tmux_conf_theme_window_status_format="#I #W"
#tmux_conf_theme_window_status_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_format="#I #W#{?window_bell_flag,,}#{?window_zoomed_flag,,}"

# window current status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_current_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_current_bg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_current_attr="bold"
tmux_conf_theme_window_status_current_format="#I #W"
#tmux_conf_theme_window_status_current_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_current_format="#I #W#{?window_zoomed_flag,,}"

# window activity status style
tmux_conf_theme_window_status_activity_fg="default"
tmux_conf_theme_window_status_activity_bg="default"
tmux_conf_theme_window_status_activity_attr="underscore"

# window bell status style
tmux_conf_theme_window_status_bell_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_window_status_bell_bg="default"
tmux_conf_theme_window_status_bell_attr="blink,bold"

# window last status style
tmux_conf_theme_window_status_last_fg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_last_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_last_attr="none"

# status left/right sections separators
tmux_conf_theme_left_separator_main=""
tmux_conf_theme_left_separator_sub="|"
tmux_conf_theme_right_separator_main=""
tmux_conf_theme_right_separator_sub="|"
#tmux_conf_theme_left_separator_main="\uE0B0"  # /!\ you don't need to install Powerline
#tmux_conf_theme_left_separator_sub="\uE0B1"   #   you only need fonts patched with
#tmux_conf_theme_right_separator_main="\uE0B2" #   Powerline symbols or the standalone
#tmux_conf_theme_right_separator_sub="\uE0B3"  #   PowerlineSymbols.otf font, see README.md

# status left/right content:
#   - separate main sections with "|"
#   - separate subsections with ","
#   - built-in variables are:
#     - #{battery_bar}
#     - #{battery_hbar}
#     - #{battery_percentage}
#     - #{battery_status}
#     - #{battery_vbar}
#     - #{circled_session_name}
#     - #{hostname_ssh}
#     - #{hostname}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{loadavg}
#     - #{mouse}
#     - #{pairing}
#     - #{prefix}
#     - #{root}
#     - #{synchronized}
#     - #{uptime_y}
#     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
#     - #{uptime_h}
#     - #{uptime_m}
#     - #{uptime_s}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_status_left="  #S | #{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized}#, %R , %d %b | #{username}#{root} | #{hostname} "

# status left style
tmux_conf_theme_status_left_fg="$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_7,$tmux_conf_theme_colour_8"
tmux_conf_theme_status_left_bg="$tmux_conf_theme_colour_9,$tmux_conf_theme_colour_10,$tmux_conf_theme_colour_11"
tmux_conf_theme_status_left_attr="bold,none,none"

# status right style
tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_13,$tmux_conf_theme_colour_14"
tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_17"
tmux_conf_theme_status_right_attr="none,none,bold"

# pairing indicator
tmux_conf_theme_pairing=""                 # U+2687
tmux_conf_theme_pairing_fg="none"
tmux_conf_theme_pairing_bg="none"
tmux_conf_theme_pairing_attr="none"

# prefix indicator
tmux_conf_theme_prefix=""                  # U+2328
tmux_conf_theme_prefix_fg="none"
tmux_conf_theme_prefix_bg="none"
tmux_conf_theme_prefix_attr="none"

# mouse indicator
tmux_conf_theme_mouse=""                   # U+2197
tmux_conf_theme_mouse_fg="none"
tmux_conf_theme_mouse_bg="none"
tmux_conf_theme_mouse_attr="none"

# root indicator
tmux_conf_theme_root="!"
tmux_conf_theme_root_fg="none"
tmux_conf_theme_root_bg="none"
tmux_conf_theme_root_attr="bold,blink"

# synchronized indicator
tmux_conf_theme_synchronized=""            # U+268F
tmux_conf_theme_synchronized_fg="none"
tmux_conf_theme_synchronized_bg="none"
tmux_conf_theme_synchronized_attr="none"

# clock style (when you hit <prefix> + t)
# you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
tmux_conf_theme_clock_colour="$tmux_conf_theme_colour_4"
tmux_conf_theme_clock_style="24"

### -- Clipboard -- ###

# in copy mode, copying selection also copies to the OS clipboard
#   - true
#   - false (default)
# on macOS, this requires installing reattach-to-user-namespace, see README.md
# on Linux, this requires xsel or xclip

tmux_conf_copy_to_os_clipboard=true

### -- User Customizations -- ###
# this is the place to override or undo settings

# increase history size
set -g history-limit 10000

# start with mouse mode enabled
set -g mouse on

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
#set -g status-keys vi
#set -g mode-keys vi

# move status line to top
#set -g status-position top

### -- TPM -- ###

# by default, launching tmux will update tpm and all plugins
#   - true (default)
#   - false

tmux_conf_update_plugins_on_launch=true

# by default, reloading the configuration will update tpm and all plugins
#   - true (default)
#   - false

tmux_conf_update_plugins_on_reload=true

# to enable a plugin, use the 'set -g @plugin' syntax:
# visit https://github.com/tmux-plugins for available plugins
set -g @plugin 'tmux-plugins/tmux-copycat'
#set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
EOF
}

# vim Text editor
install_vimrc
edit_vimrc

# oh_my_zsh Terminal Interface
install_oh_my_zsh
edit_oh_my_zsh

# tmux Terminal multiplexer
install_tmux
