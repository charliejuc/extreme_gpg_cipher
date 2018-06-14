#!/bin/bash

set -e

FILE_DIR=$(dirname $0)
FILE=$FILE_DIR/secret.txt
CIPHERED_FILE=$FILE.gpg
PASSWORD=1234

function check_if_fail () {
	if [ $1 -eq 0 ]; then
		echo -e "$2: \e[32mOK\e[0m"
	else
		echo -e "$2: \e[91mFAIL\e[0m"
	fi
}

ROUNDS=2

SCRIPT=$FILE_DIR/extreme_gpg.sh

$SCRIPT $PASSWORD $FILE $ROUNDS &> /dev/null

check_if_fail $? "No flag cipher, $ROUNDS rounds"

$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

check_if_fail $? "Decipher, $ROUNDS rounds"

$SCRIPT -e $PASSWORD $FILE $ROUNDS &> /dev/null

check_if_fail $? "Flag cipher, $ROUNDS rounds"

$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

check_if_fail $? "Decipher, $ROUNDS rounds"

ROUNDS=3

$SCRIPT $PASSWORD $FILE $ROUNDS &> /dev/null

check_if_fail $? "No flag cipher, $ROUNDS rounds"

$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

check_if_fail $? "Decipher, $ROUNDS rounds"

$SCRIPT -e $PASSWORD $FILE $ROUNDS &> /dev/null

check_if_fail $? "Flag cipher, $ROUNDS rounds"

$SCRIPT -d $PASSWORD $CIPHERED_FILE $ROUNDS &> /dev/null

check_if_fail $? "Decipher, $ROUNDS rounds"