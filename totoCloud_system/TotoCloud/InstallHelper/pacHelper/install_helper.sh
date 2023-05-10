#!/bin/sh
#FIXME:不能放在$HOME/Library/Application Support/tqqCloud/下

cd "$(dirname "${BASH_SOURCE[0]}")"
sudo mkdir -p "/Library/Application Support/tqqCloud/"
sudo cp ProxyConfHelper "/Library/Application Support/tqqCloud/"
sudo chown root:admin "/Library/Application Support/tqqCloud/ProxyConfHelper"
sudo chmod +s "/Library/Application Support/tqqCloud/ProxyConfHelper"
echo done
