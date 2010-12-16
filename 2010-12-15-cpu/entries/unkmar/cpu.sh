#!/bin/bash

declare -a CMD
declare -a P1
declare -a P2
declare -a M
declare -a R

COUNT=0
while read LINE ; do
	if [ "$LINE" != "" ]; then
		CMD[$COUNT]=`echo "$LINE" | sed 's:^\([0-9?]\).*:\1:'`
		P1[$COUNT]=`echo "$LINE" | sed "s:^[0-9?]\([0-9?]\).*:\1:"`
		P2[$COUNT]=`echo "$LINE" | sed "s:^[0-9?]\{2\}\([0-9]\).*:\1:"`
		((COUNT++))
	fi
done < $1

# setup registers
for C in {0..9}; do
	R[$C]=0
done

# setup ram
for C in {0..999}; do
	M[$C]=0
done
((M[0]--))

IP=0
while [ $IP != $COUNT ]; do
	CCMD=${CMD[$IP]}
	CP1=${P1[$IP]}
	CP2=${P2[$IP]}

	if [ "$CCMD" = '?' ]; then
		if [ "$CP1" = '?' ]; then
			echo -n "${R[$CP2]} "
		else
			echo ${R[$CP1]}
		fi
	elif [ "$CCMD" = 0 ]; then
		if [ ${R[$CP2]} != 0 ]; then
			IP=$((R[CP1] - 1))
			echo -n
		fi
	elif [ "$CCMD" = 1 ]; then
		exit
	elif [ "$CCMD" = 2 ]; then
		R[$CP1]=$CP2
	elif [ "$CCMD" = 3 ]; then
		R[$CP1]=$((R[CP1] + CP2))
	elif [ "$CCMD" = 4 ]; then
		R[$CP1]=$((R[CP1] * CP2))
	elif [ "$CCMD" = 5 ]; then
		R[$CP1]=${R[CP2]}
	elif [ "$CCMD" = 6 ]; then
		R[$CP1]=$((R[CP1] + R[CP2]))
	elif [ "$CCMD" = 7 ]; then
		R[$CP1]=$((R[CP1] * R[CP2]))
	elif [ "$CCMD" = 8 ]; then
		A=${R[$CP2]}
		R[$CP1]=${M[A]}
	elif [ "$CCMD" = 9 ]; then
		A=${R[CP2]}
		M[$A]=${R[$CP1]}
	fi
	((IP++))
done

