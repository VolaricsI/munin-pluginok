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

## $1: Határ Érték; $2: Akció [felett|alatt] akkor $3 lesz 
Csere(){
	case $2 in
	    felett) 	Muvelet='>='
	    ;;
	    alatt) 	Muvelet='<='
	    ;;
	    *)
		exit 1
	esac

	while read a; do
	    echo "${a}" 	|grep "<!-- [0-9 :-]\{19\} [A-X]\+ / [0-9]\+ --> <row><v>.\+</v></row>" -q
	    if [ $? != 0 ] ; then
		echo "${a}"
		continue
	    fi
	    Eleje=$( echo ${a}|sed 's/<row><v>.*//' )
	    Szam=$(  echo ${a}|sed 's/.*<row><v>//; s/<\/v><\/row>.*//' )
	    if [ ".${Szam}" == ".NaN" ]; then
		echo "${a}"
		continue
	    fi

	    Ret=$( awk "BEGIN { print $Szam $Muvelet $1 }" )
	    if [ ".${Ret}" == ".0" ]; then
		echo "${a}"
		continue
	    fi
	    echo "${Eleje}<row><v>${UjErtek}</v></row>"
	done
}


## $1: rrd file; $2: Határ Érték; $3: Akcio;  $4: új érték (nem szükséges akkor $2 lesz)
Setting(){
	if [ -z $4 ]; then 	UjErtek=$2
	else 			UjErtek=$4
	fi
	echo "$1	/$2/$3/${UjErtek}---"
	cp "${HELY}/$1" "${HELY}/$1.old"
	rrdtool dump "${HELY}/$1" |Csere $2 $3 ${UjErtek} >/tmp/$1
	rrdtool restore -f /tmp/$1 "${HELY}/$1"
	chown ${USER}:${GROUP} "${HELY}/$1"
	rm -f /tmp/$1
}

## $1: rrd file minta; $2: Határ Érték; $3: Akcio;   $4: új érték (nem szükséges akkor $2 lesz)
Cikl(){
    find ${HELY} |grep -v ".old$" |grep "$1" |sort |while read a; do
	fname=$( basename $a )
	Setting $fname 	$2 $3 $4
    done
}

#:::::: Start :::::::::::::::::

#Cikl 'tu20.volarics.hu-*diskstats_utilization-vgtu20rt*' 	100 felett 	NaN
#Cikl 'tu20.volarics.hu-*diskstats_utilization*' 		100 felett 	NaN
#Cikl 'tu20.volarics.hu-*diskstats_throughput*' 		1e9 felett 	NaN

#Cikl 'tu20.volarics.hu-*diskstats_throughput-sdn-*' 		1e9 felett 	NaN

Cikl 'tu20.volarics.hu-Sensors_fan-fan*'		 	2000 felett NaN

#Setting 	tu20.volarics.hu-processes-zombie-g.rrd 	100 felett NaN

#Setting 	tu20.volarics.hu-sensors_fan-fan1-g.rrd 	2000 felett NaN
#Setting 	tu20.volarics.hu-sensors_fan-fan2-g.rrd 	2000 felett NaN
#Setting 	tu20.volarics.hu-sensors_fan-fan3-g.rrd 	2000 felett NaN
#Setting 	tu20.volarics.hu-sensors_fan-fan4-g.rrd 	2000 felett NaN
#Setting 	tu20.volarics.hu-sensors_fan-fan5-g.rrd 	2000 felett NaN

#Setting 	tu20.volarics.hu-vg_vgtu20sys-free-g.rrd 	300e9 felett NaN
#Setting 	tu20.volarics.hu-vg_vgtu20sys-size-g.rrd 	300e9 felett NaN
#Setting 	tu20.volarics.hu-vg_vgtu20sys-lv_root-g.rrd 	300e9 felett NaN

#Setting 	tu20.volarics.hu-docker_memory-rTorrent-g.rrd 	5e9 felett NaN

#Setting 	tu20.volarics.hu-sensors_temp-temp4-g.rrd 	23 alatt NaN
#Setting 	tu20.volarics.hu-sensors_temp-temp5-g.rrd 	23 alatt NaN
#Setting 	tu20.volarics.hu-sensors_temp-temp6-g.rrd 	23 alatt NaN
#Setting 	tu20.volarics.hu-sensors_temp-temp8-g.rrd 	23 alatt NaN

#Setting tu20.volarics.hu-diskstats_throughput-md126_rdbytes-g.rrd 	MaxFelett 	450.000.000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126_wrbytes-g.rrd 	MaxFelett 	450000000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126-rdbytes-g.rrd 	MaxFelett 	450000000 #NaN
#Setting tu20.volarics.hu-diskstats_throughput-md126-wrbytes-g.rrd 	MaxFelett 	450000000 #NaN


#Setting 	tu20.volarics.hu-diskstats_utilization-sda_util-g.rrd 80 felett 

echo .........; read a; exit
