#init
import glob, os, shutil, subprocess, sys
print "makeanim version 0.9 by Docmudkipz"
#shell=True is being used under the assumption that the end user is not willing harm his/her own system, nor has he/she modified the shell in a harmful way
#I am not held responsible for any damage done to the users own system because of something that the user modified in the script, input to the script, or user modified programs
#shell=True will be removed later on

def main():
	clean()
	file()
	fps()
	screen()
	ar()
	vars()
	quest()
	convert()
	compcheck()
	config()
	print "Done!"
	quit()

def clean():
	if os.path.isfile('output.rgb'):
		os.remove('output.rgb')
	if os.path.isfile('config.txt'):
		os.remove('config.txt')
	if os.path.isfile('anim'):
		os.remove('anim')
	if os.path.isfile('bottom_anim'):
		os.remove('bottom_anim')
	if os.path.isfile('compressedanim'):
		os.remove('compressedanim')
	if os.path.isfile('frames.rgb.0'):
		kek = glob.glob('frames.rgb.*')
		for lol in kek:
			os.remove(lol)
	return

def file():
	#Accept file and check if it exists, loop if it doesn't
	global source
	source = raw_input("What is the file you want to convert? (ex. hi.gif): ")
	if os.path.isfile(source):
		return
	else:
		print "Please input a valid file"
		file()

def fps():
	#Loop the fps input until it is a valid integer
	maxfps = 30
	minfps = 1
	global fps
	fps = int(input("What is your desired framerate, between %s and %s: " % (minfps, maxfps)))
	if fps < minfps or fps > maxfps:
		print "This framerate is either too high or too low, try again"
		fps()
	else:
		return

def screen():
	#Top or bottom check. Loops if input is invalid
	global screen
	screen = raw_input("Please type what screen this is being generated for, Top or Bottom: ")
	if screen == 'Top' or screen == 'Bottom' or screen == 'top' or screen == 'bottom':
		return
	else:
		print "Try again."
		screen()

def ar():
	global ar
	ar = raw_input("Would you like to keep the aspect ratio of the file(This may degrade quality)[Yes/No]: ")
	if ar == 'Yes' or ar == 'Y' or ar == 'yes' or ar == 'y' or ar == '' or ar == 'No' or ar == 'N' or ar == 'no' or ar == 'n':
		return
	else:
		print "Please try again"
		ar()

def vars():
	#Set vars
	global size, rename, s, ff
	if screen == 'Top' or screen == 'top':
		if ar == 'Yes' or ar == 'Y' or ar == 'yes' or ar == 'y' or ar == '':
			ff = "ffmpeg -y -i %s -vf fps=%i,scale=\"\'if(gt(a,5/3),400,-2)\':\'if(gt(a,5/3),-2,240)\'\",pad=400:240:\'if(gt(a,5/3),0,trunc((400-240*a)/2))\':\'if(gt(a,5/3),trunc((240-400/a)/2),0)\':black,transpose=1 -pix_fmt bgr24 output.rgb" % (source, fps)
		else:
			ff = "ffmpeg -y -i %s -vf fps=%i,scale=400:240:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb" % (source, fps)
		rename = 'anim'
		s = '-t'
	else:
		if ar == 'Yes' or ar == 'Y' or ar == 'yes' or ar == 'y' or ar == '':
			ff = "ffmpeg -y -i %s -vf fps=%i,scale=\"\'if(gt(a,4/3),320,-2)\':\'if(gt(a,4/3),-2,240)\'\",pad=320:240:\'if(gt(a,4/3),0,trunc((320-240*a)/2))\':\'if(gt(a,4/3),trunc((240-320/a)/2),0)\':black,transpose=1 -pix_fmt bgr24 output.rgb" % (source, fps)
		else:
			ff = "ffmpeg -y -i %s -vf fps=%i,scale=320:240:flags=lanczos,transpose=1 -pix_fmt bgr24 output.rgb" % (source, fps)
		rename = 'bottom_anim'
		s = '-b'
	return

def quest():
	#Static or Video/gif, loops if input is invalid
	global wew
	wew = raw_input("Input Static for a static image  or Gif for an animated format(Gif, mp4, etc.): ")
	if wew == 'static' or wew == 'Static' or wew == 'Gif' or wew == 'gif':
		return
	else:
		print "Try again."
		quest()

def convert():
	#Conversion steps
		#Use a non shell=True call if the host is running Windows
		if sys.platform == 'win32':
			subprocess.call(ff)
		else:
			subprocess.call(ff, shell=True)
		os.rename ('output.rgb',rename)
		if wew == 'Static' or wew == 'static':
			static()
		return

def static():
	#Steps to generate a static image, will always be smaller than an animation
	os.rename(rename, "output.rgb")
	fps = 1
	time = int(input("How long would you like the image to last in seconds?: "))
	if sys.platform == 'win32':
	#Create frames and combine them in a similar manner to the batch script
		for x in range (0, time):
			shutil.copy('output.rgb', 'frames.rgb.%s' % x)
		#The copy command has read/write issues without shell=True
		subprocess.call("copy /b frames.rgb.* %s" % rename, shell=True)
	else:
		#Run cat like in the shell script
		subprocess.call("for i in $(seq 1 %i); do cat output.rgb >> %s; done" % (time, rename), shell=True)
	if os.path.isfile('frames.rgb.1'):
		kek = glob.glob('frames.rgb.*')
		for lol in kek:
			os.remove(lol)
	os.remove('output.rgb')
	return

def compcheck():
	#Check for ban9comp and calls the function if it exists alongside the script, else skip
	global ban9, lz
	lz = ''
	if os.path.isfile('ban9comp') or os.path.isfile('ban9comp.exe'):
		if os.path.isfile('ban9comp'):
			ban9 = './ban9comp'
		else:
			ban9 = 'ban9comp.exe'
		comp()
		return
	else:
		return

def comp():
	#Asks if compression is wanted, perform if confirmed
	choice = raw_input("Would you like your file to be compressed?[Yes/No] ")
	if choice == 'Yes' or choice == 'Y' or choice == 'yes' or choice == 'y' or choice == '':
		#Same as in the convert function
		if sys.platform == 'win32':
			subprocess.call("%s c %s < %s  > compressedanim" % (ban9, s, rename))
		else:
			subprocess.call("%s c %s < %s  > compressedanim" % (ban9, s, rename), shell=True)
		#Set vars for compressed size check
		origsize = os.stat(rename)
		origsize = origsize.st_size
		threshold = origsize * 0.5
		compsize = os.stat('compressedanim')
		compsize = compsize.st_size
		#Deletes compressed animation if size check isn't passed, else sets compression var for config generation
		if compsize > threshold:
			print "The compressed size is too large for BootAnim9, it will be deleted. Try reducing the framerate."
			os.remove('compressedanim')
			return
		else:
			global lz
			lz = 'lzd'
			os.rename('compressedanim',rename)
			return
	else:
		return

def config():
	#Prompts for config generation, skip and exits if unwanted
	q2 = raw_input("Would you like your config file to be generated?[Yes/No] ")
	if q2 == 'Yes' or q2 == 'Y' or q2 == 'yes' or q2 == 'y' or q2 == '':
		#Generate config file
		config = open("config.txt", "w")
		config.write("%i %s" % (fps, lz))
		config.close()
		return
	else:
		print "The config file was not generated and must be created by the user as config.txt"
		print "If this is a static image, use an fps of 1"
		return

main()
#end
