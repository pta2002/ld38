#!/usr/bin/env bash
./package.sh
./package-win32
./package-linux
./package-macos
cd build
butler push linux pta2002/o:linux
butler push win32 pta2002/o:windows
butler push o-macos.app pta2002/o:macos
