#!/usr/bin/env bash

# @file install.sh
# @brief install script for all configuration


# @description check if the user is root then execute the command
#
# @arg $1 a bash command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
exec_root(){
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

# @description Install The ultimate Vim configuration (vimrc) https://github.com/amix/vimrc
# @exitcode 0 If successfull and install vimrc
# @exitcode 1 On failure
install_vimrc(){
	exec_root apt-get install vim
	git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
	sh ~/.vim_runtime/install_awesome_vimrc.sh
	# check if the line exist then write it in .bashrc
	grep -qxF 'alias vi=vim' ~/.bashrc || echo 'alias vi=vim' >> ~/.bashrc
}

# @description Install The ultimate Vim configuration (vimrc) https://github.com/amix/vimrc
# @exitcode 0 If successfull and edit vimrc
# @exitcode 1 On failure
edit_vimrc(){
	sed -i -e 's/let g:NERDTreeWinPos = "right"/let g:NERDTreeWinPos = "left"/g' ~/.vim_runtime/vimrcs/plugins_config.vim
    touch .vim_runtime/vimrcs/my_configs.vim
    echo 'set number' > .vim_runtime/vimrcs/my_configs.vim
}

