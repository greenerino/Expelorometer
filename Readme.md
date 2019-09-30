# Expelorometer - A simple experience tracking addon for Classic WoW - V. 0.2
I originally created this addon to get familiar with Lua and addon creation for Classic WoW. I figured a simple tool that grabs and displays data from gameplay would be a good introduction.

## Installation
If you wish to install this addon, simply download the source code (only need the .toc and .lua files), and put them in your addon folder (World of Warcraft\\_classic\_\Interface\AddOns) within a folder named `Expelorometer`.

## Usage
Like I said, this is a simple addon. Click the start button to start recording, stop to pause, and reset to reset the time and experience gained. You may use the stop button to pause and resume the recording later. Reset can be used while the recording is active or stopped.
Type `/xp` to show the window if it has been closed.

## Known Issues and ToDos
* Currently only updates rates when exp comes in. Planning to have it update every x seconds, e.g. 5 seconds.
* Save rates upon logout
* Currently unsure if all experience sources are handled
