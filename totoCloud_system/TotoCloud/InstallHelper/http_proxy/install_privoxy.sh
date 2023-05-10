#!/bin/sh
# 生成/Users/chenzhidong/Library/Application Support/tqqCloud/privoxy-3.0.28.static/privoxy及libpcre.1.dylib；并创建相关快捷方式

cd "$(dirname "${BASH_SOURCE[0]}")"
privoxyVersion=3.0.28.static
mkdir -p "$HOME/Library/Application Support/tqqCloud/privoxy-$privoxyVersion"
cp -f privoxy "$HOME/Library/Application Support/tqqCloud/privoxy-$privoxyVersion/"
cp -f libpcre.1.dylib "$HOME/Library/Application Support/tqqCloud/privoxy-$privoxyVersion/"
rm -f "$HOME/Library/Application Support/tqqCloud/privoxy"
ln -s "$HOME/Library/Application Support/tqqCloud/privoxy-$privoxyVersion/privoxy" "$HOME/Library/Application Support/tqqCloud/privoxy"
ln -sf "$HOME/Library/Application Support/tqqCloud/privoxy-$privoxyVersion/libpcre.1.dylib" "$HOME/Library/Application Support/tqqCloud/libpcre.1.dylib"
echo done
