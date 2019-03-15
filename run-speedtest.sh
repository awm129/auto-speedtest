#! /bin/bash

dir="/srv/speedtest"
dat="speedtest-full.csv"
extract="speedtest.csv"
last="speedtest-last.csv"

st="/usr/local/bin/speedtest-cli"

#
# set the max size of the csv file.
# there are 3 runs every hour, and I want 90 days of history
#
maxSz=3*24*90
maxSz=$(($maxSz + 1))

function removeLine()
{
	local file=$1
	local sz=$(wc -l $file | cut -f1 -d' ')

	# need at least 3 lines
	sz=$(($sz - 3))

	echo $file is $sz big. max is $maxSz

	if [[ $sz -lt $maxSz ]]; then
		return
	fi

	tmp=$(mktemp)
	head -n 1 $file >> $tmp
	tail -n +$(($sz - $maxSz)) $file >> $tmp
	mv $tmp $file
	chmod 644 $file

	sz=$(wc -l $file | cut -f1 -d' ')
	echo $file is now $sz
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

# filter the result, selecting just the fields we need (speedtest-cli v2.1.1)
out=$(echo $out | cut -d, -f$(($fcount-6)),$(($fcount-2)),$(($fcount-3)))

# extract the date and convert to local time
d=$(date -d "$(echo $out | cut -d, -f1)" -Iseconds)

# re-assemble the csv line
out="$d,$(echo $out | cut -d, -f2,3)"

# append to extract
echo $out >> $dir/$extract

#
# prevent the files from getting yuge
#
removeLine $dir/$extract
removeLine $dir/$dat


