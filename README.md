# auto-swap-cleaner
Clears up Linux swap when the system doesn't do it automatically

## Purpose
If you're like me who uses Chrome and has 17 tabs open at any time and has 4GB RAM then you'll notice that your system will start moving RAM to swap when RAM is at 95% or even at 80% depending upon the swapiness of system, regardless of that whenever you close Chrome about 150MB of swap remains there if you use a dock like plack-dock you'll notice that the animations of plank dock aren't smooth whisker menu takes time to open and system feels overall sluggish. 

Similarly try to hibernate system when your RAM is 50% or high after resuming system the swap will be 25% system will feel even more sluggish this is because swap is on HDD and moving data from HDD to RAM takes time sometimes system won't automatically move swap to memory even though it has space in memory which keeps system sluggish.

I discussed this problem on Arch Linux Group on Facebook and came to conclusion that doing swapoff and swapon again fixes the problem! Doing that manually is waste of time though so I made this script that will do it automatically in the background. It is supposed to speed up your system by moving swap to memory when system doesn't do it automatically.

## Installation
Firstly  we need to make sure that swapoff and swapon can be run with sudo asking for password
`sudo nano /etc/sudoers`
Scroll down to the User privilege section where you see your username.
Under the line `USERNAME ALL=(ALL) ALL` add the following
`USERNAME ALL = (root) NOPASSWD: /usr/bin/swapoff, /usr/bin/swapon`
Which will make it like this 
```bash
##
## User privilege specification
##
root ALL=(ALL) ALL
USERNAME ALL=(ALL) ALL
USERNAME ALL = (root) NOPASSWD: /usr/bin/swapoff, /usr/bin/swapon
## Uncomment to allow members of group wheel to execute any command
```
Now you can try to run `sudo swapoff -a -v && sudo swapon -a` in new terminal if it doesn't ask for password you're good.

### Start-up
Save the script somewhere perhaps clone git repo in your home directory by `git clone https://github.com/fellchase/auto-swap-cleaner.git`
Make sure script `auto_swap_cleaner.sh` is started with your sytem. 
For doing this in XFCE you can go to Session and Startup

### Restart the computer
Try loading lot of Chrome tabs open your task manager you'll see swap go up, after that close chrome, swap will go down some will be left, it'll be cleaned by auto_swap_cleaner.sh

## Enable notifications (optional)
You can enable notifications via `notify-send` in auto_swap_cleaner.sh if you want to debug something by uncommenting lines with command `notify-send` in the script.

## Relevant problems on Linux Forum 
This script can solve these problems
- [Slowdown after resume from suspend(Unsolved)](https://bbs.archlinux.org/viewtopic.php?id=199922)
- [Ubuntu 16.04 LTS too slow after suspend and resume](https://askubuntu.com/questions/792605/ubuntu-16-04-lts-too-slow-after-suspend-and-resume)

## Support
If you found this useful or want to share opinions about it you can contact me on [@fellchase](https://twitter.com/fellchase) you can also send a tip via [paypal.me/fellchase](https://www.paypal.me/fellchase)
