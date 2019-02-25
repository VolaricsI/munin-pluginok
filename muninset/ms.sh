#!/bin/bash
#
#	Create by Voli

#:::::: Fix beallitasok :::::::
HELY=/var/lib/munin/volarics.hu
USER=munin
GROUP=munin
#:::::: Beallitasok :::::::::::
MuninSet=`dirname $0`/muninset
#:::::: Ellenorzesek ::::::::::
#:::::: functions :::::::::::::

calc(){ awk "BEGIN { print $* }"  
}
## $1: Max Érték; "NaN" lesz helyette
Nullazo(){
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
	    Ret=$( calc "$Szam >= $1" )
	    if [ ".${Ret}" == ".0" ]; then
		echo "${a}"
		continue
	    fi
	    echo "${Eleje}<row><v>NaN</v></row>"
	done
}

## $1: rrd file; $2: Max Érték; $3: Ha van akkor erre írja át a $2-t
#Setting(){
#	echo "$1/$2/$3---"
#	cp "${HELY}/$1" "${HELY}/$1.old"
#	rrdtool dump "${HELY}/$1" |${MuninSet} $2 $3 >/tmp/$1
#	rrdtool restore -f /tmp/$1 "${HELY}/$1"
#	chown ${USER}:${GROUP} "${HELY}/$1"
#	rm -f /tmp/$1
#}

## $1: rrd file; $2: Max Érték; "NaN"-re írja átt.
Setting0(){
	echo "$1/$2---"
	cp "${HELY}/$1" "${HELY}/$1.old"
	rrdtool dump "${HELY}/$1" |Nullazo $2 >/tmp/$1
	rrdtool restore -f /tmp/$1 "${HELY}/$1"
	chown ${USER}:${GROUP} "${HELY}/$1"
#	rm -f /tmp/$1
}

#:::::: Start :::::::::::::::::

##Setting0	tu20.volarics.hu-Idokep_-Kulso_homerseklet-g.rrd		40

#Setting0 	tu20.volarics.hu-Idokep_paratartalom-Relativ_paratartalom-g.rrd	85
##Setting0 	tu20.volarics.hu-Idokep_paratartalom-Belso_paratartalom-g.rrd	85

#Setting0	tu20.volarics.hu-Idokep_legnyomas-Relativ_legnyomas-g.rrd	1100

Setting0	tu20.volarics.hu-Idokep_leg-Abszolut_legnyomas-g.rrd	50
Setting0	tu20.volarics.hu-Idokep_leg-Relativ_legnyomas-g.rrd	50


echo .........; read a; exit
<!-- 2016-07-24 02:00:00 CEST / 1469318400 --> <row><v>3.2896000000e+01</v></row>
<!-- 2016-07-25 02:00:00 CEST / 1469404800 --> <row><v>NaN</v></row>
