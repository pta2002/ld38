#!/usr/bin/env bash
zip build/game.love *.lua res/* -ry
adb push build/game.love /sdcard/
adb shell am start -S -n "org.love2d.android/.GameActivity" -d "file:///sdcard/game.love"
