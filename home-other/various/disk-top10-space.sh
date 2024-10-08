#/bin/bash
if [[ -z $1 ]]; then
	echo "No parameter. Using current."
	du -a -x . | sort -n -r | head -n 10
else
	du -a -x $1 | sort -n -r | head -n 10
fi
