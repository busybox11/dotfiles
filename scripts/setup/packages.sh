#!/bin/bash

usage() {
    echo "usage: $0 <target_list>"
    exit 1
}

target_list=$1
if [ -z "$target_list" ]; then
    usage
fi

if [ "$target_list" == "all" ]; then
    target_lists=(wm programs shell apps)
else
    target_lists=($target_list)
fi

# install packages
for list in ${target_lists[@]}; do
    echo "installing packages from $list"
    packages=$(cat meta/packages/$list)
    yay -S --needed $packages
done