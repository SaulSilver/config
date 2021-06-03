#!/usr/bin/env bash

echo "Depend on go rust clang, nice nerd fonts..."

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
&& mkdir -p ${HOME}/.config/nvim \
&& mkdir -p ${HOME}/.config/ctags \
&& mkdir -p ${HOME}/.local/share/nvim \
&& ln -fs  ${PWD}/resources/init.vim ${HOME}/.config/nvim/init.vim \
&& ln -fs  ${PWD}/resources/ctagsrc ${HOME}/.config/ctags/ctagsrc \
&& nvim --headless +PlugInstall +qall \
&& ${HOME}/.local/share/nvim/plugged/youcompleteme/install.py --all \
