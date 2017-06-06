#! /bin/bash

dir="/srv/speedtest"
dat="speedtest-full.csv"
extract="speedtest.csv"
last="speedtest-last.csv"

st="/usr/local/bin/speedtest-cli"

#
# set the max size of the csv file.
# there are 3 runs every hour, and I want 45 days of history
#
maxSz=3*24*45
maxSz=$(($maxSz + 1))

function removeLine()
{
	local file=$1
	local sz=$(wc -l $file | cut -f1 -d '')

	if [[ $wc < $maxSz ]]; then
		return
	fi

	tmp=$(mktemp)
	head -n 1 $file >> $tmp
	tail -n +3 $file >> $tmp
	mv $tmp $file
}

#
# create csv files if they don't exist
#i
if [ ! -d $dir ]; then
	mkdir -p $dir
fi

if [ ! -s $dir/$dat ]; then
	touch $dir/$dat
	$st --csv-header > $dir/$dat
fi

if [ ! -s $dir/$extract ]; then
	touch $dir/$extract
	$st --csv-header | cut -d, -f4,7,8 > $dir/$extract
fi

if [ ! -s $dir/$last ]; then
	touch $dir/$last
	$st --csv-header > $dir/$last
fi

#
# run the speedtest
#
out=$(/usr/local/bin/speedtest-cli --csv)

#
# overwrite the last csv
#
$st --csv-header > $dir/$last
echo $out >> $dir/$last

#
# append to the dat file
#
echo $out >> $dir/$dat

#
# now we want to slice the csv to get just the data we need (timestamp, upload, download)
#
fcount=$(echo $out | tr -cd ',' | wc -c)
fcount=$(($fcount + 1))
echo $out | cut -d, -f$(($fcount-4)),$(($fcount-1)),$fcount >> $dir/$extract

#
# prevent the files from getting yuge
#
removeLine $dir/$extract
removeLine $dir/$dat


