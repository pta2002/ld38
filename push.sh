#!/usr/bin/env bash
./package.sh
./package-win32
./package-linux
./package-macos
cd build
butler push linux pta2002/o:linux-postjam
butler push win32 pta2002/o:windows-postjam
butler push o-macos pta2002/o:macos-postjam
