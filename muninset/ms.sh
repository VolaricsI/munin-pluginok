#!/bin/bash
#
#	Create by Voli

#:::::: Fix beallitasok :::::::
HELY=/var/lib/munin/volarics.hu
USER=munin
GROUP=munin
#:::::: Beallitasok :::::::::::
#:::::: Ellenorzesek ::::::::::
#:::::: functions :::::::::::::

calc(){ awk "BEGIN { print $* }"
}

## $1: Max Érték; X >= $1 akkor $2 lesz 
MaxFelett(){
	if [ -z $2 ]; then 	UjErtek=$1
	else 			UjErtek=$2
	fi
	while read a; do
	    echo "${a}" 	|grep "<!-- [0-9 :-]\{19\} [A-X]\+ / [0-9]\+ --> <row><v>.\+</v></row>" -q
	    if [ $? != 0 ] ; then
		echo "${a}"
		continue
	    fi
	    Eleje=$( echo ${a}|sed 's/<row><v>.*//g;' )
	    Szam=$(  echo ${a}|sed 's/.*<row><v>//g; s/<\/v><\/row>.*//g' )
	    if [ ".${Szam}" == ".NaN" ]; then
		echo "${a}"
		continue
	    fi
	    Ret=$( calc "$Szam >= $1" )
	    if [ ".${Ret}" == ".0" ]; then
		echo "${a}"
		continue
	    fi
	    echo "${Eleje}<row><v>${UjErtek}</v></row>"
	done
}

MinAlatt(){
	while read a; do
	    echo "${a}"	|	grep "<!-- [0-9 :-]\{19\} [A-X]\+ / [0-9]\+ --> <row><v>.\+</v></row>" -q
	    if [ $? != 0 ] ; then
		echo "${a}"
		continue
	    fi
	    Eleje=$( echo ${a}|sed 's/<row><v>.*//g;' )
	    Szam=$(  echo ${a}|sed 's/.*<row><v>//g; s/<\/v><\/row>.*//g' )
	    if [ ".${Szam}" == ".NaN" ]; then
		echo "${a}"
		continue
	    fi
	    Ret=$( calc "$Szam <= $1" )
	    if [ ".${Ret}" == ".0" ]; then
		echo "${a}"
		continue
	    fi
	    echo "${Eleje}<row><v>NaN</v></row>"
	done
}


## $1: rrd file; $2: Akcio;  $3: Határ Érték; $4: új érték
Setting(){
	echo "$1	/$2	/$3/$4---"
	cp "${HELY}/$1" "${HELY}/$1.old"
	rrdtool dump "${HELY}/$1" |$2 $3 $4 >/tmp/$1
	rrdtool restore -f /tmp/$1 "${HELY}/$1"
	chown ${USER}:${GROUP} "${HELY}/$1"
	rm -f /tmp/$1
}

## $1: rrd file minta; $2: Akcio;  $3: Határ Érték; $4: új érték
Cikl(){
    find ${HELY} |grep -v ".old$" |grep "$1" |sort |while read a; do
	fname=$( basename $a )
#	Setting $fname 	MaxFelett 	1000 NaN
	Setting $fname 	$2 	$3 $4
    done
}



#:::::: Start :::::::::::::::::
#
#Cikl 'tu20.volarics.hu-*diskstats_utilization*' 	MaxFelett 	1000 NaN
#Cikl 'tu20.volarics.hu-*diskstats_throughput*' 	MaxFelett 	1000000000 NaN

#SettingMaxFelettMax 	tu20.volarics.hu-diskstats_throughput-md126_rdbytes-g.rrd 	500000000
#SettingMaxFelettMax 	tu20.volarics.hu-diskstats_throughput-md126_wrbytes-g.rrd 	500000000

#Setting tu20.volarics.hu-diskstats_throughput-md126_rdbytes-g.rrd 	MaxFelett 	450.000.000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126_wrbytes-g.rrd 	MaxFelett 	450000000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126-rdbytes-g.rrd 	MaxFelett 	450000000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126-wrbytes-g.rrd 	MaxFelett 	450000000 #NaN

Setting 	tu20.volarics.hu-threads-threads-g.rrd 	MaxFelett 	2e3 NaN




echo .........; read a; exit
