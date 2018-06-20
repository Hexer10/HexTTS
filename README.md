# HexTTS
This was tested only on CS:GO & CentOS 7.2

# Requirements
 * [System2 Extension](https://forums.alliedmods.net/showthread.php?t=146019)
 * [Late Downloads Extension](https://forums.alliedmods.net/showthread.php?t=305153)
 *  [Lame](http://lame.sourceforge.net/about.php) installed (`yum install lame` or `apt-get install lame`)

# Installation
 * Clone(/Download) the repo and upload the smx to your sm plugins folder.
 * Refresh the plugins.
 
# Usage
 * sm_getSound \<lang\> \<file name without .mp3\> \<text\> -> Download Server & Connected clients the sound.
 * sm_playLast -> Play the last downloaded sound.
 
# How it works?
 1. Downloads the .mp3 file from google TTS API
 2. Convert it to the right Sample Rate
 3. Make clients to download it
 * [Video](https://youtu.be/A3egPTy9hhA)
 
# TODO
 * Move mp3 files to fastdl.
 
