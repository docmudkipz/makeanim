#!/bin/sh
minfps=5
maxfps=30
echo "What is the name of the file you want to convert(with extension)?"
read input

echo "What do you want your framerate to be, any number between $minfps and $maxfps?"
read fps
	if [ $fps -lt $minfps ]; then
		echo "Please pick a number greater than 5"
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
		rename="anim"
		rm "anim"
	else
		size="320:240"
		rename="bottom_anim"
		rm "bottom_anim"
fi
ffmpeg -y -i $input -vf fps=$fps,scale=$size:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
mv output.rgb $rename

rm config
cp configs/$fps ./
mv $fps config

exit
