import sys
import pathlib
import os
import zipfile
import subprocess
import pyuac
import shutil

LOVE_DIR = "C:/Program Files/LOVE" # is this inaccurate?
# then edit this ^
# (check if its there first, when i installed love it didnt add it there, but it should add itself)
#path_environ = os.environ.get("path").split(";")
#for p in path_environ:
#    if "love" in p.lower():
#        LOVE_DIR = p.replace(";", "")

print(__file__)

"""
Hey! If you're using this, I hope it's useful! Feel free to use parts of this script to learn how this works!!

A bit of commentary from the coder here bc why not

Honestly, this was very difficult to create, the stuff that was mostly new to me was using pyuac to request admin perms and also the
command that is put on the Love2D documentation page (https://www.love2d.org/wiki/Game_Distribution)

Funnily enough, the day I made this is also the first day I tried Love2D, but I do already know lua from things like fnf and roblox

Also, if you're checking here to figure out why you're getting errors, I'll tell you a few I got while testing.

Any error relating to main.lua:
You probably don't have a main.lua in your working directory, go to the directory with your Love2D game and run this script there.

Directory not found or file not found:
Do you have Love2D installed? Confirm by running `love --version`
"""

if not "win" in sys.platform:
    print("Sorry! This script can only be run on windows :(")
    exit()

if not "main.lua" in os.listdir(os.curdir):
    print("Warning: main.lua not found, might be in the wrong directory, please do NOT report this as a bug, thx!!")
gameDir = pathlib.Path(__file__).parent

def zipfolder(foldername, target_dir):
    zipobj = zipfile.ZipFile(foldername + '.love', 'w', zipfile.ZIP_DEFLATED)
    rootlen = len(target_dir) + 1
    for base, dirs, files in os.walk(target_dir):
        for file in files:
            print(base)
            if not "zip" in file and not "Build" in file and not ".love" in file and not "build" in base: # dont include build files in the archive
                fn = os.path.join(base, file)
                zipobj.write(fn, fn[rootlen:])
    print(zipobj.testzip())

# with zipfile.ZipFile(os.path.join(str(gameDir), f"{gameDir.name}.love"), "w") as zip:
#     for base, dirs, files in os.walk(str(gameDir)):
#         for f in files:
#             if not "Build.py" in f and not ".love" in f and not "build" in f:
#                 # do not zip itself or an already created .love file
#                 print(f"Zipping file {f}")
#                 zip.write(os.path.join(base, f))
#     print(zip.testzip())

if os.path.exists(os.path.join(str(gameDir), f"{gameDir.name}.love")):
    print(f"{gameDir.name}.love and ALL its contents will be deleted!")
    if input("Continue? (Y/N)").lower() == "n":
        exit(0)
    else:
        # yes, continue
        os.remove(os.path.join(str(gameDir), f"{gameDir.name}.love"))

if os.path.exists(os.path.join(str(gameDir), "build", f"{gameDir.name}")):
    print(f"{os.path.join(str(gameDir), "build", f"{gameDir.name}")} and ALL its contents will be deleted!")
    if input("Continue? (Y/N)").lower() == "n":
        exit(0)
    else:
        try:
            shutil.rmtree(os.path.join(str(gameDir), "build", f"{gameDir.name}"))
        except:
            pass
            # no point in letting errors happen here, files get overriden anyway

zipfolder(gameDir.name, str(gameDir))

if not os.path.exists(str(gameDir.joinpath("build"))):
    os.mkdir(str(gameDir.joinpath("build")))
    os.mkdir(str(gameDir.joinpath("build").joinpath(gameDir.name)))
if not os.path.exists(str(gameDir.joinpath("build").joinpath(gameDir.name))):
    os.mkdir(str(gameDir.joinpath("build").joinpath(gameDir.name)))

workingDir = os.curdir # just in case (you dont really need it but yk)
os.chdir(LOVE_DIR)

cmd = f"Get-Content love.exe,{str(gameDir.joinpath(f"{gameDir.name}.love"))} -Encoding Byte | Set-Content {gameDir.name}.exe -Encoding Byte"
cmdcmd = f"copy /b love.exe+\"{str(gameDir.joinpath(f"{gameDir.name}.love"))}\" {gameDir.name}.exe"
print(cmdcmd)

if not pyuac.isUserAdmin():
    print("Must be launched as admin, relaunching.")
    pyuac.runAsAdmin()
else:
    proc = subprocess.Popen(cmdcmd, shell=True)
    proc.wait()
    print(os.listdir(os.curdir))
    for f in os.listdir(os.curdir):
        if not os.path.isdir(f) and (".dll" in f or "license.txt" in f or f"{gameDir.name}.exe" in f):
            shutil.copy(os.path.join(os.curdir, f), os.path.join(str(gameDir.joinpath("build").joinpath(gameDir.name)), f))
    try:
        os.remove(os.path.join(os.curdir, f"{gameDir.name}.exe"))
    except:
        pass
    print("Done!")
    print(f"Your build is at: {str(gameDir.joinpath("build").joinpath(gameDir.name))}")
    shouldrun = input("Run the build? (Y/N)")
    if shouldrun.lower() == "y":
        subprocess.run(str(gameDir.joinpath("build").joinpath(gameDir.name).joinpath(f"{gameDir.name}.exe")))
#print(proc.stdout)