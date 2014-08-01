#!/bin/bash

####################################################################
# File: I_Hate_Taxes.sh
# Author: Chris Murphy
# Date: 2007-02-23
# Purpose: Failed attempt to fool Benford's law, maybe someday I'll
#          look at it again, but I'd rather not go to jail.
####################################################################

function show_usage {
    echo "                  ===========  WARNING ==========="
    echo "  This script tried to get around Benford's law, but the math fundamentally"
    echo "  flawed so DON'T USE IT (as I never did :) ) because it will actually backfire"
    echo "  and more than likely cause you to get audited by the IRS !!!!!!!!!!!!!!!!!"
    echo ""
    echo "  Usage for the brave and/or stupid:"
    echo "      -h or --help shows this message"
    echo "      iterations = how many random numbers do you want to have to choose from"
    echo "      how_many_numbers = what's the largest numbers allowed to be in the pool"
    echo ""
    echo "      ./I_Hate_Taxes.sh <iterations> <how_many_numbers>"
    echo "  Example:"
    echo "      ./I_Hate_Taxes.sh 5 9000"
    echo "      4751 1520 112 5672 74"
    exit
}


if [ "$1" = "" ]; then
    show_usage
fi
if [ "$1" = "-h" ]; then
    show_usage
fi
if [ "$1" = "--help" ]; then
    show_usage
fi
if [ "$2" = "" ]; then
    show_usage
fi


iterations=$(seq 1 $1)
how_many_numbers=$2

for i in $iterations; do
for r in $(($RANDOM%$how_many_numbers)); do echo $r;done
done
