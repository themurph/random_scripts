#!/bin/sh
#
# I can never remember how the $[$RANDOM%5] function works
# so now I won't forget.

[ $[$RANDOM%5] == 0 ] && echo "Bang!!!"||echo "Click!"
