#/bin/bash
echo "Mergerfs dedup dry run, shows rm commands."
mergerfs.dedup -vv -E snapraid.content -E mounttest.ismounted -E snapraid.conf -E snapraid.conf.bak -D jradxl1ftp  /mnt/mergerfs
exit 0

