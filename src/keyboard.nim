import winim, os

type
    HotKeys* {.pure.} = enum
     CTRL_A = 0

    Keys* {.pure.} = enum
     LBUTTON = 0x01,
     RBUTTON = 0x02,
     CANCEL = 0x03,
     MBUTTON = 0x04,
     XBUTTON1 = 0x05,
     XBUTTON2 = 0x06,
     RESERVED = 0x07,
     BACK = 0x08,
     TAB = 0x09,
     CLEAR = 0x0C,
     RETURN = 0x0D,
     SHIFT = 0x10,
     CONTROL = 0x11,
     MENU = 0x12,
     PAUSE = 0x13,
     CAPITAL = 0x14,
     KANA = 0x15,
     IME_ON = 0x16,
     JUNJA = 0x17,
     FINAL = 0x18,
     HANJA = 0x19,
     IME_OFF = 0x1A,
     ESCAPE = 0x1B,
     CONVERT = 0x1C,
     NONCONVERT = 0x1D,
     ACCEPT = 0x1E,
     MODECHANGE = 0x1F,
     SPACE = 0x20,
     PRIOR = 0x21,
     NEXT = 0x22,
     END = 0x23,
     HOME = 0x24,
     LEFT = 0x25,
     UP = 0x26,
     RIGHT = 0x27,
     DOWN = 0x28,
     SELECT = 0x29,
     PRINT = 0x2A,
     EXECUTE = 0x2B,
     SNAPSHOT = 0x2C,
     INSERT = 0x2D,
     DELETE = 0x2E,
     HELP = 0x2F,


     ZERO = 0x30,
     ONE = 0x31,
     TWO = 0x32,
     THREE = 0x33,
     FOUR = 0x34,
     FIVE = 0x35,
     SIX = 0x36,
     SEVEN = 0x37,
     EIGHT = 0x38,
     NINE = 0x39,


     A = 0x41,
     B = 0x42,
     C = 0x43,
     D = 0x44,
     E = 0x45,
     F = 0x46,
     G = 0x47,
     H = 0x48,
     I = 0x49,
     J = 0x4A,
     K = 0x4B,
     L = 0x4C,
     M = 0x4D,
     N = 0x4E,
     O = 0x4F,
     P = 0x50,
     Q = 0x51,
     R = 0x52,
     S = 0x53,
     T = 0x54,
     U = 0x55,
     V = 0x56,
     W = 0x57,
     X = 0x58,
     Y = 0x59,
     Z = 0x5A,
     LWIN = 0x5B,
     RWIN = 0x5C,
     APPS = 0x5D,
     LSHIFT = 0xA0,
     RSHIFT = 0xA1,
     LCTRL = 0xA2,
     RCTRL = 0xA3,
     LALT = 0xA4,
     RALT = 0xA5,
    
    Callback = proc(info: ptr KBDLLHOOKSTRUCT)
    Event = object
     callBack: Callback
    Keyboard* = object
     Events: seq[Event]
     SpecialEvents: seq[Event]
var
    keyboard: Keyboard

proc hook(code: int32, wParam: WPARAM, lParam: LPARAM): LRESULT =
    var events = keyboard.Events
    let info: ptr KBDLLHOOKSTRUCT = cast[ptr KBDLLHOOKSTRUCT](lParam)
    if code == HC_ACTION:
        #echo(info.vkCode)
        for event in events:
            let cbFn = event.callBack
            cbFn(info)
    result = CallNextHookEx(cast[HHOOK](NULL), code, wParam, lParam);


proc initKeyboard*() = 
    var instance = Keyboard(
        Events: @[]
    )
    keyboard = instance

proc onStroke*(cbFn: Callback) = 
    var event = Event(
            callBack: cbFn
        )
    add(keyboard.Events, event)

proc startLoop() = 
    var Msg: MSG
    while GetMessage(&Msg, cast[HWND](NULL), 0, 0) > 0:
        try:
            TranslateMessage(&Msg)
            discard DispatchMessage(&Msg)
        except:
            quit(0)

proc startKeyboard*() = 
    let hHook = SetWindowsHookExA(
    WH_KEYBOARD_LL,
    cast[HOOKPROC](hook),
    GetModuleHandle(NULL),
    cast[DWORD](NULL)
    )
    if hHook == 0:
        echo("[-] Failed to Setup Hook.")
        quit(-1)
    startLoop()

proc pressKey*(key: Keys | int, durationInMs: int = 10, release: bool = true) = 
    var input: INPUT
    input.type = INPUT_KEYBOARD
    input.ki.wScan = 0
    input.ki.time = 0
    input.ki.dwExtraInfo = 0
    input.ki.wVk = cast[uint16](key)
    input.ki.dwFlags = 0
    SendInput(1,&input, cast[int32](sizeof(INPUT)))
    input.ki.dwFlags = KEYEVENTF_KEYUP
    if release:
        sleep durationInMs
        SendInput(1,&input, cast[int32](sizeof(INPUT)))

proc releaseKey*(key: Keys | int) =
    var input: INPUT
    input.type = INPUT_KEYBOARD
    input.ki.wScan = 0
    input.ki.time = 0
    input.ki.dwExtraInfo = 0
    input.ki.wVk = cast[uint16](key)
    input.ki.dwFlags = 0
    input.ki.dwFlags = KEYEVENTF_KEYUP
    SendInput(1,&input, cast[int32](sizeof(INPUT)))


proc pressKeys*(keys: seq[Keys | int], coolDown: int = 10) =
    for key in keys:
        pressKey(key)
        sleep coolDown

proc pressHotKey*(hotkey: HotKeys) =
    case hotkey
    of CTRL_A:
        pressKey(Keys.LCTRL, release = false)
        pressKey(Keys.A, release = false)
        releaseKey(Keys.LCTRL)
        releaseKey(Keys.A)
        
proc pressHotKey*(k1, k2: Keys) = 
    pressKey(k1, release = false)
    pressKey(k2, release = false)
    releaseKey(k1)
    releaseKey(k2)

proc pressHotKey*(keys: varargs[Keys]) = 
    for key in keys:
        pressKey(key, release = false)

    for key in keys:
        releaseKey(key)

proc getCursorPos*[T]: (T, T) =
    var point: POINT
    GetCursorPos(&point)
    let x = cast[T](point.x)
    let y = cast[T](point.y)
    return (x,y)

proc leftClick*() =
    let pos = getCursorPos[DWORD]()
    let x = pos[0]
    let y = pos[1]
    mouse_event(MOUSEEVENTF_LEFTDOWN, x, y, 0, 0);
    mouse_event(MOUSEEVENTF_LEFTUP, x, y, 0, 0);

proc rightClick*() =
    let pos = getCursorPos[DWORD]()
    let x = pos[0]
    let y = pos[1]
    mouse_event(MOUSEEVENTF_RIGHTDOWN, x, y, 0, 0);
    mouse_event(MOUSEEVENTF_RIGHTUP, x, y, 0, 0);