#!/bin/sh
#FIXME:不能放在$HOME/Library/Application Support/tqqCloud/下

cd "$(dirname "${BASH_SOURCE[0]}")"
sudo mkdir -p "/Library/Application Support/tqqXNB/"
echo done
