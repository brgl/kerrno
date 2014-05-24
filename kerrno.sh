#!/bin/sh

# kerrno: get definitions, locations and descriptions for
# errno numbers
#
# Copyright (C) 2014 Bartosz Golaszewski <bartekgola@gmail.com>

FILEPTRN=".*errno.*\.[ch]$"
ERRNOPTRN="\#define[\ \t]+E[A-Z0-9]+[\ \t]+[0-9]+[\ \t]+" 

usage()
{
	echo "$0: get info for errno number"
	echo "Usage:"
	echo "\t$0 <errno numbers>"
	echo "\tExample: $0 -18 34 128"
}

if [ "$#" -eq "0" ] || ([ "$#" -eq "1" ] && [ "$1" = "--help" ])
then
	usage
	exit
fi

for WANTED in $@
do
	case ${WANTED#-} in
		''|*[!0-9]*)
			echo "$WANTED: not a number";
			continue;
			;;
	esac

	test "$WANTED" -lt "0" && WANTED=$(echo -n $WANTED | cut -d'-' -f2)

	echo "Errno $WANTED:"
	find ./ -regex "$FILEPTRN" -exec grep -nPH "$ERRNOPTRN" {} \; \
		| tr -s ':' ' ' \
		| tr -s '\t' ' ' \
		| cut -d' ' -f1,2,4,5 | while read FILE LINE ERRNO NUM
	do
		if [ "$NUM" -eq "$WANTED" ]
		then
			echo -n "\t$ERRNO ("
			echo -n "$(head $FILE -n $LINE | tail -1 | cut -d'*' -f2)"
			echo ") defined in $FILE:$LINE" 
		fi
	done
done

