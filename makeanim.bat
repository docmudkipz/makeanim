@ECHO OFF
set minfps=1
set maxfps=30

IF [%1]==[] (
	set /p input="what is the name with extension of the file you want to convert?(ex. hi.gif)"
) else (
	set input=%1
)

for %%i in (%input%) do (
	echo "%%~xi"
	set ext="%%~xi"
	)
cls

IF exist "C:\Program Files\ImageMagick-6.9.3-Q16\convert.exe" (
	set convert="C:\Program Files\ImageMagick-6.9.3-Q16\convert.exe"
) else (
	set convert="C:\Program Files (x86)\ImageMagick-6.9.3-Q16\convert.exe"
)

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
			
cls
CHOICE /M "Press A for top screen or B for bottom screen" /C:ab
	IF ERRORLEVEL 2 GOTO bot
	IF ERRORLEVEL 1 GOTO top

:top
	set res=400:240
	set magick="400x240"
	set name=anim
	del anim
	GOTO img
	
:bot
	set res=320:240
	set magick="320x240"
	set name=bottom_anim
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

	%convert% %input% -flatten -resize %magick% -channel BGR -separate -channel RGB -combine -rotate 90 %name%.rgb
	
	for /l %%x in (1, 1, %frame%) do copy /b %name%.rgb %name%.frame.%%x
		copy /b %name%.frame.* %name%
		del *.frame.*
		del %name%.rgb
	GOTO end
	
:ff
cls
ffmpeg -y -i %input% -vf fps=%fps%,scale=%res%:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
rename output.rgb %name%
goto end

:end
del config
cp configs\%fps% .\
rename "%fps%" config
exit
