#!/bin/bash

set -e

PASSWORD=$1
FILE=$2
CIPHERED_FILE=$FILE.gpg
ROUNDS=$3
DEFAULT_ROUNDS=5

if [ ! "$PASSWORD" ]; then
	>&2 echo "Password is required"
	exit 1
fi

if [ ! "$FILE" ] || [ ! -f "$FILE" ]; then
	>&2 echo "File is required"
	exit 1
fi

if [ ! $ROUNDS ]; then
	ROUNDS=$DEFAULT_ROUNDS
fi

function decipher () {
	gpg -d --batch --passphrase $1 $2
}

_FILE=$FILE
_CIPHERED_FILE=$CIPHERED_FILE

for i in $(seq $ROUNDS); do
	echo "Round $i"
	
	decipher $PASSWORD $_FILE > $_CIPHERED_FILE

	shred -zfu $_FILE	

	_FILE=$_CIPHERED_FILE
	_CIPHERED_FILE=$_CIPHERED_FILE.$i	 

	decipher $PASSWORD $_FILE > $_CIPHERED_FILE

	shred -zfu $_FILE

	if [ $i -ne $ROUNDS ]; then 
		_FILE=$_CIPHERED_FILE
		_CIPHERED_FILE=$CIPHERED_FILE.$(($i + 1))
	fi
done

mv $_CIPHERED_FILE $( echo "$(basename $_CIPHERED_FILE)" | cut -d "." -f -2 )
