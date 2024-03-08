import keyboard, winim


initKeyboard()
pressKey(Keys.F, durationInMs = 1000) # pressing the F key for 1 second.

pressKey(Keys.F, release = false) # pressing F but not releasing.
releaseKey(Keys.F) # releasing manually.

pressKeys(@[Keys.A,Keys.M,Keys.R]) # pressing keys from sequence.
pressKeys(@[Keys.LCTRL,Keys.A]) # using special keys.

pressHotKey(HotKeys.CTRL_A) # predefined hotkey enum.

pressHotKey(Keys.LWIN,Keys.LSHIFT,Keys.S) # taking a screenshot. 

leftClick() # left mouse click.

rightClick() # right mouse click.

var (x , y) = getCursorPos[int]() # getting cursor position.

proc callback(info: ptr KBDLLHOOKSTRUCT) = 
    echo("[*] Keyboard Hit!")
    echo(info.vkCode)

onStroke(callback) # call this function once a key is hit.

startKeyboard() # start the actual loop, very important.


