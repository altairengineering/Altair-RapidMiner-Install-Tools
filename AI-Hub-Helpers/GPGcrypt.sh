#!/bin/bash
# GPGcrypt.sh
# by Anthony Kiehl
# 20250428
export GPG_TTY=$(tty)

[ $# -eq 0 ] && { echo "GPGcrypt.sh
by Anthony Kiehl
Make backups before using this tool, just in case.
Encrypt a file:
$0 -e file.name
Decrypt a file:
$0 -d file.name"; exit 1; }



while getopts 'de:' OPTION; do
	case "$OPTION" in
		d)
			echo "Decrypting file $2"
			cat $2 | gpg --pinentry-mode loopback --decrypt -o $2
			;;
		e)
			echo "Encrypting file $2"
                        #cat $2 | gpg --batch --no-tty --encrypt -o $2
                        cat $2 | gpg -c -o $2
			;;

		esac
	done
echo RELOADAGENT | gpg-connect-agent
shift "$(($OPTIND -1))"

