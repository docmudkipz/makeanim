@ECHO OFF
set minfps=1
set maxfps=30
set version=0.1

del output.bin

cls
echo makeanim v%version% by Docmudkipz

IF [%1]==[] (
	set /p input="What is the file you want to convert? (ex. hi.gif) "
) else (
	set input=%1
)

:fps
	cls
	set /p fps="Please input your framerate, between %minfps% and %maxfps%: "

		if /I %fps% LSS %minfps% (
			echo Please pick a number greater or equal than %minfps%!
			Pause >nul
			GOTO fps
		)

		if /I %fps% GTR %maxfps% (
			echo Please pick a number lower or equal than %maxfps%!
			Pause >nul
			GOTO fps
		)

		for /f "delims=" %%i in ('powershell -Command "'{0:x}' -f %fps%"') do set hex=%%i
		set hex=0x%hex%
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
	CHOICE /M "Is this an animation? " /C:yn
	IF ERRORLEVEL 1 GOTO ff
	IF ERRORLEVEL 2 GOTO static

:static
	cls
	set /p time="How many seconds do you want the image to last?: "
	set /a "frame=%time%*%fps%"
	del %name%.rgb

	convert.exe %input% -flatten -resize %magick% -channel BGR -separate -channel RGB -combine -rotate 90 %name%.rgb

	if ERRORLEVEL 1 (
		echo ERROR! convert.exe (ImageMagick) couldn't be found! Aborting...
		goto end
	)

	for /l %%x in (1, 1, %frame%) do copy /b %name%.rgb %name%.frame.%%x
		copy /b %name%.frame.* output.bin
		del *.frame.*
		del %name%.rgb
	GOTO compress

:ff
	cls
	REM ffmpeg only outputs correctly when the extension is .rgb so...
	ffmpeg -y -i %input% -vf fps=%fps%,scale=%res%:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
	rename output.rgb %name%
	goto compress

:compress
	CHOICE /M "Do you want this to be compressed with ban9comp? " /C:yn
	IF ERRORLEVEL 2 GOTO end
	IF ERRORLEVEL 1 GOTO comp

:comp
	ban9comp.exe c %s% < %name% > compressed_%name%

	if ERRORLEVEL 1 (
		echo WARNING! ban9comp.exe couldn't be executed! Make sure it's in PATH!
		del compressed_%name%
		set comp=0x00
		goto end
	)
	REM in casy ban9comp.exe can't be launched, bail out

	set comp=0x01
	FOR /F "usebackq" %%A IN ('compressed_%name%') DO set compsize=%%~zA

	FOR /F "usebackq" %%A IN ('%name%') DO set threshold=%%~zA 
	FOR /F "delims=" %%G in ('powershell %threshold%*0.5') DO set threshold=%%G
	REM set threshold size

	if /I %compsize% GTR %threshold% (
		echo This file is too large after compression, so it will be deleted. Try reducing the framerate.
		pause
		del compressed_%name%
		REM compressed animation is too large to provide a tolerable experience, delete
		set comp=0x00
		GOTO end
	) else (
		del %name%
		ren compressed_%name% %name%
		REM delete uncompressed animation and rename the compressed one
	)
	goto end

:end
	copy NUL config
	powershell -Command "[Byte[]] $x = %hex%,%comp%; set-content -value $x -encoding byte -path config"
	pause
