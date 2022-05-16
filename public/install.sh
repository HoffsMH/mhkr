#!/bin/bash

pushd ~
mkdir personal
cd personal
git clone git://github.com/hoffsmh/dotfiles.git
cd dotfiles/bootstrap
./run.sh
