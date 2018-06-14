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

function cipher () {
	gpg -c --batch --passphrase $1 --cipher-algo $2 --personal-digest-preferences SHA512 --s2k-mode 3 --s2k-count 65000000 -o $4 $3
}

_FILE=$FILE
_CIPHERED_FILE=$CIPHERED_FILE

for i in $(seq $ROUNDS); do
	echo "Round $i"
	
	cipher $PASSWORD AES256 $_FILE $_CIPHERED_FILE

	shred -zfu $_FILE

	_FILE=$_CIPHERED_FILE
	_CIPHERED_FILE=$_CIPHERED_FILE.$i

	cipher $PASSWORD BLOWFISH $_FILE $_CIPHERED_FILE

	shred -zfu $_FILE

	if [ $i -ne $ROUNDS ]; then 
		_FILE=$_CIPHERED_FILE
		_CIPHERED_FILE=$CIPHERED_FILE.$(($i + 1))
	fi
done

mv $_CIPHERED_FILE $CIPHERED_FILE
