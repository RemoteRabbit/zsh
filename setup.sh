#! /bin/env bash

ln -sf $HOME/repos/personal/zsh/.zshenv $HOME/.zshenv

mkdir -p $HOME/.config/zsh
ln -sf $HOME/repos/personal/zsh/* $HOME/.config/zsh

mkdir -p $HOME/.config/zsh/stats
