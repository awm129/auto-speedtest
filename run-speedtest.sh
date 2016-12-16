#! /bin/bash

dir="/srv/speedtest"
dat="speedtest-full.csv"
extract="speedtest.csv"

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
	local sz=$(wc -l $file)

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
#
if [ ! -s $dir/$dat ]; then
	mkdir -p $dir
	touch $dat
	$st --csv-header > $dir/$dat
fi

if [ ! -s $dir/$extract ]; then
	mkdir -p $dir
	touch $extract
	$st --csv-header | cut -d, -f4,7,8 > $dir/$extract
fi

#
# run the speedtest
#
out=$(/usr/local/bin/speedtest-cli --csv)

#
# write the data to the csv
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


