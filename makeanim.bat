@ECHO OFF
set minfps=1
set maxfps=30

IF [%1]==[] (
	set /p input="what is the name with extension of the file you want to convert?(ex. hi.gif)"
) else (
	set input=%1
)

FOR /F "usebackq" %%A IN ('%input%') DO set threshold=%%~zA 
FOR /F "delims=" %%G in ('powershell %threshold%*0.4') DO set threshold=%%G
cls
del output.bin

:fps
	cls
	set /p fps="What do you want your framerate to be, any number between %minfps% and %maxfps%: "
		if /I %fps% LSS %minfps% (
			echo "Please pick a number greater than 5"
			Pause >nul
			GOTO fps  )
		if /I %fps% GTR %maxfps%	(
			echo "Please pick a number lower than 30"
			Pause >nul
			GOTO fps )
		for /f "delims=" %%i in ('powershell -Command "'{0:x}' -f %fps%"') do set hex=%%i
		set hex=0x%hex%
		echo %hex%
	cls
		CHOICE /M "Press A for top screen or B for bottom screen" /C:ab
			IF ERRORLEVEL 2 GOTO bot
			IF ERRORLEVEL 1 GOTO top

:top
	set res=400:240
	set magick="400x240"
	set name=anim
	set s=-t
	set comp=0x00
	del anim
	GOTO img
	
:bot
	set res=320:240
	set magick="320x240"
	set name=bottom_anim
	set s=-b
	set comp=0x00
	del bottom_anim
	GOTO img

:img
	cls
	CHOICE /M "Is this a static image? A for yes B for no: " /C:ab
	IF ERRORLEVEL 2 GOTO ff
	IF ERRORLEVEL 1 GOTO static
	
:static
	cls
	set /p time="How long in seconds do you want the image to last?: "
	set /a "frame=%time%*%fps%"
	del %name%.rgb

	convert.exe %input% -flatten -resize %magick% -channel BGR -separate -channel RGB -combine -rotate 90 %name%.rgb
	
	for /l %%x in (1, 1, %frame%) do copy /b %name%.rgb %name%.frame.%%x
		copy /b %name%.frame.* output.bin
		del *.frame.*
		del %name%.rgb
	GOTO compress
	
:ff
	cls
	ffmpeg -y -i %input% -vf fps=%fps%,scale=%res%:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
	rename output.rgb output.bin
	goto compress

:compress
	CHOICE /M "Do you want this to be compressed using ba9comp? A for yes B for no: " /C:ab
	IF ERRORLEVEL 2 GOTO end
	IF ERRORLEVEL 1 GOTO comp
	
:comp
	ban9comp.exe c %s% < output.bin > compressed.bin
	rename compressed.bin %name%
	set comp=0x01
	del output.bin
	FOR /F "usebackq" %%A IN ('%name%') DO set compsize=%%~zA
	if /I %compsize% GTR %threshold% (
		del %name%
		echo "This file after compression is too large, it will be decompressed for you"
		pause
		rename %name% bfore.bin
		ba9comp.exe d %s% < bfore.bin > output.bin
		rename output.bin %name%
		set comp=0x00
		GOTO end )
	
	goto end
:end
	copy NUL EmptyFile.txt
	rename EmptyFile.txt config
	powershell -Command "[Byte[]] $x = %hex%,%comp%; set-content -value $x -encoding byte -path config"
	exit