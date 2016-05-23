#!/bin/sh
minfps=1
maxfps=30
version="0.1"

echo "makeanim v.$version by Docmudkipz"
echo "What is the name of the file you want to convert(ex. hi.gif)?"
read input
compression="\x00"

clear

#Receive FPS value
echo "Please input your framerate, between $minfps and $maxfps"
read fps
	if [ $fps -lt $minfps ]; then
		echo "Please pick a number greater than 1"
		read -p "Press enter to continue"
		sh makeanim.sh
	elif [ $fps -gt $maxfps ]; then
		echo "Please pick a number less than 30"
		read -p "Press enter to continue"
		sh makeanim.sh
	else
	#Set fps in hex
	base=$(echo "obase=16; $fps" | bc)
fi

clear
#Set other variables
echo "0 for top screen and 1 for bottom screen"
read number
	if [ $number = 0 ]; then
		size="400:240"
		magic=""400x240""
		rename="anim"
		rm "anim"
		s=-t
	else
		size="320:240"
		magic=""320x240""
		rename="bottom_anim"
		rm "bottom_anim"
		s=-b
fi

clear

echo "0 for static image, 1 for animation"
read img
clear

	if [ $img = 0 ]; then
		echo "How long in seconds do you want the image to last?"
		read second
#Create static anim
		let frames=$[fps*second]
		convert $input -resize $magic -flatten -channel BGR -separate -channel RGB -combine -rotate 90 $rename.rgb
		for i in $(seq 1 $frames); do cat $rename.rgb >> $rename; done
		rm $rename.rgb
		clear

		echo "Would you like this to be compressed? 0 for no, 1 for yes."
		read compress

		clear
			if [ $compress = 1 ]; then
					#Set threshold
					uncomp=$(stat -c%s "$rename")
					cut='0.5'
					threshold=$(echo $uncomp*$cut | bc)
					threshold=${threshold%.*}
					./ban9comp c $s < $rename > compressed_$rename
					rm $rename
					mv compressed_$rename $rename
					clear
					#Set Compression and find comrpessed size
					compression="\x01"
					comp=$(stat -c%s $rename)
					if [ $comp -gt $threshold ]; then
						clear
						echo "This file is too large after compression, so it will be deleted. Try reducing the framerate."
						read -p ""
						rm $rename
						exit

					fi
			fi
					compression3="\x$base$compression"
					rm output.bin
					echo -n -e $compression3 > config
					exit

	else
clear
#Create Raw Dump
		ffmpeg -y -i $input -vf fps=$fps,scale=$size:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
		mv output.rgb $rename
		echo "Would you like this to be compressed? 0 for no, 1 for yes."
		read compress
		clear
			if [ $compress = 1 ]; then
					#Set threshold
					uncomp=$(stat -c%s "$rename")
					cut='0.5'
					threshold=$(echo $uncomp*$cut | bc)
					threshold=${threshold%.*}
					./ban9comp c $s < $rename > compressed_$rename
					rm $rename
					mv compressed_$rename $rename
					clear
					#Set Compression and find comrpessed size
					compression="\x01"
					comp=$(stat -c%s $rename)
					if [ $comp -gt $threshold ]; then
						clear
						echo "This file is too large after compression, so it will be deleted. Try reducing the framerate."
						read -p ""
						rm $rename
						exit

					fi
			fi
					compression3="\x$base$compression"
					rm output.bin
					echo -n -e $compression3 > config
					exit
fi
