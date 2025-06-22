# Pong
Pong was a game built for the Atari in 1972. I have decided to build upon the concept of Pong to make this game

## Contents
[How to build](#how-to-build) - Build instructions  
[Modding](#modding) - Modding documentation  
[Credits](#credits) - All the credits

## How to build
First, go ahead and install [LOVE](https://love2d.org/).
Now, if you open a terminal in the folder with all the source, you can just run:  
```
love .
```  
But if you're fine with that, lets go ahead and build it!  

Firstly, make sure you have Python installed, and that you're on **windows**. I'm sorry, but this build script only support windows. If you're not, you'll have to follow the build instructions [here](https://love2d.org/wiki/Game_Distribution) manually.

Now, you need to make sure you know where you installed LOVE. Go ahead and open up Build.py in an IDE of your choice.  
Now check if the path is accurate, if not, change it to where LOVE actually is on your machine.  

Next, open up a terminal as _**administrator**_ (important or the build might be broken). (right click start > Windows Terminal (Admin))

Now `cd` into the source folder if you haven't already.

Now you can run:
```
python Build.py
```
Wait for it to finish, then you'll have a new folder called "build`, go into there, then the folder inside, and now you'll find the executable.

### Important
LOVE requires that you *keep* the license.txt file in the build, so don't delete it.

## Modding
You can add your own Lua scripts that will be run after you pick your difficulty and play.

These scripts should be in: `%appdata%/LOVE/Pong`, make a folder inside of there called "scripts", and put all your Lua scripts in there.

The documentation for these scripts is the same as [LOVE's documentation](https://love2d.org/wiki/Main_Page).

Though do note that support for these scripts is limited, at the moment, you cannot change Pong specific stuff (paddle positions, speeds, etc), you can only make your own stuff and use those, and along with those limits, love.draw seems to break the game (overrides the game's love.draw????), so be careful when using it.

## Credits
- LOVE - The framework used to create this game
- Moonshine - The source of the shaders and effects