#HOW TO USE?

##ADVICE

You need to remember the number of rounds used.

##CIPHER
```bash
./extreme_gpg.sh $PASSWORD $FILE $ROUNDS
```
OR
```bash
./extreme_gpg.sh -e $PASSWORD $FILE $ROUNDS
```

##DECIPHER
```bash
./extreme_gpg.sh -d $PASSWORD $FILE $ROUNDS
```
##TESTING
```bash
./tests.sh
```
##REQUIRED LIBRARIES

Gpg2 and shred.
