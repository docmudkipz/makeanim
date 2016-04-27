#!/bin/sh
minfps=1
maxfps=30
echo "What is the name of the file you want to convert(with extension)?"
read input

echo "What do you want your framerate to be, any number between $minfps and $maxfps?"
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
clear
fi

echo "0 for top screen and 1 for bottom screen"
read number
	if [ $number = 0 ]; then
		size="400:240"
		magic=""400x240""
		rename="anim"
		rm "anim"
	else
		size="320:240"
		magic=""320x240""
		rename="bottom_anim"
		rm "bottom_anim"
fi

echo "0 for static image, 1 for animation"
read img
	if [ $img = 0 ]; then
		echo "How long in seconds do you want the image to last?"
		read second
		let frames=$[fps*second]
		convert $input -resize $magic -flatten -channel BGR -separate -channel RGB -combine -rotate 90 $rename.rgb
		for i in $(seq 1 $frames); do cat $rename.rgb >> $rename; done
		rm $rename.rgb
		rm config
		cp ./configs/$fps ./
		mv $fps config
		exit

	else	

		ffmpeg -y -i $input -vf fps=$fps,scale=$size:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
		mv output.rgb $rename
		rm config
		cp ./configs/$fps ./
		mv $fps config
		exit

fi
