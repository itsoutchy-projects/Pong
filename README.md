# Pong
Pong was a game built for the Atari in 1972. I have decided to build upon the concept of Pong to make this game

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

Next, open up a terminal in _**administrator**_ (important or the build might be broken).

Now `cd` into the source folder if you haven't already.

Now you can run:
```
python Build.py
```
Wait for it to finish, then you'll have a new folder called "build`, go into there, then the folder inside, and now you'll find the executable.

### Important
LOVE requires that you *keep* the license.txt file in the build, so don't delete it.

## Credits
- LOVE - The framework used to create this game
- Moonshine - The source of the shaders and effects