#!/bin/bash

set -e

FILE_DIR=$(dirname $0)
TYPE=$1

if [ "$TYPE" == '-e' ] || ( [ "$TYPE" != '-e' ] && [ "$TYPE" != '-d' ] ); then
	if [ "$TYPE" == '-e' ]; then
		PASSWORD=$2
		FILE=$FILE_DIR/$(basename $3)
		CIPHERED_FILE=$FILE.gpg
		ROUNDS=$4
	else
		TYPE='-e'
		PASSWORD=$1
		FILE=$FILE_DIR/$(basename $2)
		CIPHERED_FILE=$FILE.gpg
		ROUNDS=$3
	fi
elif [ $TYPE == '-d' ]; then
	PASSWORD=$2
	FILE=$FILE_DIR/$(basename $3)
	CIPHERED_FILE=$FILE.gpg
	ROUNDS=$4
fi

DEFAULT_ROUNDS=5

if [ ! "$PASSWORD" ]; then
	>&2 echo "Password is required"
	exit 1
fi

if [ ! "$FILE" ] || [ ! -f "$FILE" ]; then
	if [ "$FILE" ]; then
		>&2 echo "File \"$FILE\" does not exist"
	else
		>&2 echo "File is required"
	fi
	exit 1
fi

if [ ! $ROUNDS ]; then
	ROUNDS=$DEFAULT_ROUNDS
fi

function cipher () {
	gpg -c --batch --passphrase $1 --cipher-algo $2 --personal-digest-preferences SHA512 --s2k-mode 3 --s2k-count 65000000 -o $4 $3
}

function decipher () {
	gpg -d --batch --passphrase $1 $2
}

function secure_delete () {
	shred -zfu $1
}

_FILE=$FILE
_CIPHERED_FILE=$CIPHERED_FILE

if [ $TYPE == '-e' ]; then
	for i in $(seq $ROUNDS); do
		echo "Round $i"
		
		cipher $PASSWORD AES256 $_FILE $_CIPHERED_FILE

		secure_delete $_FILE

		_FILE=$_CIPHERED_FILE
		_CIPHERED_FILE=$_CIPHERED_FILE.$i

		cipher $PASSWORD BLOWFISH $_FILE $_CIPHERED_FILE

		secure_delete $_FILE

		if [ $i -ne $ROUNDS ]; then 
			_FILE=$_CIPHERED_FILE
			_CIPHERED_FILE=$CIPHERED_FILE.$(($i + 1))
		fi
	done

	mv $_CIPHERED_FILE $CIPHERED_FILE
elif [ $TYPE == '-d' ]; then
	for i in $(seq $ROUNDS); do
		echo "Round $i"
		
		decipher $PASSWORD $_FILE > $_CIPHERED_FILE

		secure_delete $_FILE	

		_FILE=$_CIPHERED_FILE
		_CIPHERED_FILE=$_CIPHERED_FILE.$i	 

		decipher $PASSWORD $_FILE > $_CIPHERED_FILE

		secure_delete $_FILE

		if [ $i -ne $ROUNDS ]; then 
			_FILE=$_CIPHERED_FILE
			_CIPHERED_FILE=$CIPHERED_FILE.$(($i + 1))
		fi
	done

	mv $_CIPHERED_FILE $FILE_DIR/$( echo "$(basename $_CIPHERED_FILE)" | cut -d "." -f -2 )
fi
