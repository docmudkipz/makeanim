@ECHO OFF
set minfps=5
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
	set name=anim
	del anim
	GOTO ff
:bot
	set res=320:240
	set name=bottom_anim
	del bottom_anim
	GOTO ff

:ff
cls
ffmpeg -y -i %input% -vf fps=%fps%,scale=%res%:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb
rename output.rgb %name%

del config
cp configs\%fps% .\
rename "%fps%" config

exit