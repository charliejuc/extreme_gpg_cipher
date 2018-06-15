#!/bin/bash

set -e

FILE_DIR=$(dirname $0)
DEEP=$1
FILE=$FILE_DIR/secret.txt
CIPHERED_FILE=$FILE.gpg
PASSWORD=1234

if [ ! $DEEP ]; then
	DEEP=3
else
	MAX_DEEP=5
	
	if [ $DEEP -gt $MAX_DEEP ] && [ "$2" != '--force' ]; then
		>&2 echo "Max rounds deep is \"${MAX_DEEP}\", you have passed \"${DEEP}\", auto overwritten \"${DEEP}\" => \"${MAX_DEEP}\""

		DEEP=$MAX_DEEP
	fi
fi

function check_if_fail () {
	if [ $1 -eq 0 ]; then
		echo -e "$2: \e[32mOK\e[0m"
	else
		echo -e "$2: \e[91mFAIL\e[0m"
	fi
}

SCRIPT=$FILE_DIR/extreme_gpg.sh

for i in $(seq $DEEP); do
	ROUNDS=$i

	$SCRIPT $PASSWORD $FILE $ROUNDS &> /dev/null

	check_if_fail $? "No flag cipher, $ROUNDS rounds"

	$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

	check_if_fail $? "Decipher, $ROUNDS rounds"

	$SCRIPT -e $PASSWORD $FILE $ROUNDS &> /dev/null

	check_if_fail $? "Flag cipher, $ROUNDS rounds"

	$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

	check_if_fail $? "Decipher, $ROUNDS rounds"
done
