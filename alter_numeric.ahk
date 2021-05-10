#SingleInstance ignore ; Never run more than one instance at a time.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; HotKey Config

; Control &, Shift &, Alt & are used instead of ^, +, ! to improve reliability.
; As modifier key presses are simulated in Alter function this was causing the wrong hotkey 
; combos to fire during key repeats and successions without actually touching these modifier keys.
; This means choosing between using the same Modifiers used in Alter or using multiple modifiers
; On the bright side, this syntax is less cryptic and idiosyncratic resulting in higher readability
; for anyone that doesn't regularly code in AutoHotKey Lang, yet still obvious to those that do.

; Macro 1, 2
F21:: TabPrev()
F22:: TabNext()
; Macro 3, 4
F23:: Alter("Sub", 1)
F24:: Alter("Add", 1)
; Macro 5, 6
F15:: Alter("Sub", 0.1)
F16:: Alter("Add", 0.1)
; Macro 7, 8
F17:: Alter("Sub", 0.01)
F18:: Alter("Add", 0.01)

; Shift + Macro 1, 2
Shift & F21:: TabPrev()
Shift & F22:: TabNext()
; Shift + Macro 3, 4
Shift & F23:: Alter("Sub", 0.001)
Shift & F24:: Alter("Add", 0.001)
; Shift + Macro 5, 6
Shift & F15:: Alter("Sub", 0.0001)
Shift & F16:: Alter("Add", 0.0001)
; Shift + Macro 7, 8
Shift & F17:: Alter("Sub", 0.00001)
Shift & F18:: Alter("Add", 0.00001)

; Ctrl + Macro 1, 2
Control & F21:: TabPrev()
Control & F22:: TabNext()
; Ctrl + Macro 3, 4
Control & F23:: Alter("Sub", 10)
Control & F24:: Alter("Add", 10)
; Ctrl + Macro 5, 6
Control & F15:: Alter("Sub", 100)
Control & F16:: Alter("Add", 100)
; Ctrl + Macro 7, 8
Control & F17:: Alter("Sub", 1000)
Control & F18:: Alter("Add", 1000)

; Alt + Macro 1, 2
Alt & F21:: TabPrev()
Alt & F22:: TabNext()
; Alt + Macro 3, 4
Alt & F23:: Alter("Div", 2)
Alt & F24:: Alter("Mul", 2)
; Alt + Macro 5, 6
Alt & F15:: Alter("Div", 10)
Alt & F16:: Alter("Mul", 10)
; Alt + Macro 7, 8
Alt & F17:: Alter("Div", 255)
Alt & F18:: Alter("Mul", 255)

; Alter function and Timers for Async Subroutines

; I have taken a less conventional approach to Clipboard exploitation and management that strongly 
; favors performance and low response times to allow for fast successive key presses and key repeats
; I have mainly tested this with Unity Editor (2020+) on Windows 10 but it should also work
; with many other applications that have numerical text input fields. You may need to adjust the
; constants and expressions / commands below to suit your application(s) needs and tune reliability.
; Having said that, I performed limited testing, but I am not sure of the exact reliability of my 
; async clipboard restoration, as reliability and simplicity is not the goal here. Speed is the primary focus.
; So if making 100% sure you never lose the contents of your clipboard is of a high importance,
; this is not for you. I suggest seeking well established examples with simpler methods and higher Sleep / delayed
; response times. 

; However, if you value being able to perform maths operations and transformations on parameter / property sheets
; in GUI applications in real-time like an absolute maniac on your keyboard, and retaining clipboard contents is
; just nice to have most of the time, then this may be for you.

; There are also user32.dll based clipboard "paste wait" methods that are more or less broken in 64-bit Windows
; as far as I and anyone else in public forums can seem to tell. There is also the forthcoming AHK v2's Dynarun
; method, but v2 is still in an early Alpha state as of this writing, and I figured others might benefit
; from a solution made with AHK v1 / AutoHotkey_L (1.1.32.00)

SelectAll()
{
    Send {Control down}a{Control up}
}

Copy()
{
    Send {Control down}c{Control up}
}

Paste()
{
    Send {Control down}v{Control up}
}

TabNext()
{
    Send {Tab down}{Tab up}
}

TabPrev()
{
    Send {Shift down}{Tab down}{Tab up}{Shift up}
}

ForceUpdateFast()
{
    TabNext()
    Sleep 3
    TabPrev()
    Sleep 3
}

ForceUpdateSlow()
{
    TabNext()
    Sleep 33
    TabPrev()
    Sleep 33
}

Alter(Function, AlterValue)
{
    static ClipValue := ""
    static ClipSaved := ""
    local ClipSavedTemp := ""
    static RestoreAttempts := 0
    static ClipRestored := True
    static ActiveRecently := False
    static ActiveNow := False

    if (ClipRestored && !ActiveNow && !ActiveRecently) ; first run since last ActiveRecently
    {
        ClipSaved := ClipboardAll ; Backup Clipboard contents
        ClipRestored := False ; reset status
        RestoreAttempts := 0
    }

    if (!ActiveNow) ; Async / non-blocking race condition prevention for successive key presses
    {
        ActiveNow := True ; Lock Clipboard access
        Clipboard := "" ; Init Clipboard
        SelectAll()
        Copy()
        ClipWait 1
        ClipValue := Clipboard ; Write clipboard contents as string to temporary variable

        if ClipValue is number ; Verify this is a number in case hotkey was called by mistake
        {
            switch Function ; Apply the requested operation to value
            {
                case "Add": ClipValue := ClipValue + AlterValue
                case "Sub": ClipValue := ClipValue - AlterValue
                case "Mul": ClipValue := ClipValue * AlterValue
                case "Div": ClipValue := ClipValue / AlterValue
            }

            ClipValue := RegExReplace(ClipValue, "S)(\.\d*?)0*?$|(\d*?)\.0*?$", "$1$2", Limit:=1) ; Trim trailing chars
            Clipboard := ClipValue ; Write value back to Clipboard
            ClipWait 1
            ClipValue := "" ; Free memory
            Paste()
            Sleep 3 ; Minimum effective update rate. Increase if needed for your app
            ; ForceUpdateFast() ; Needed for some apps to update. Use ForceUpdateSlow() if app still has problems
            ; ForceUpdateSlow()
        }
        else ; ClipValue not a number, so don't paste anything
        {
            ; MsgBox % "ClipValue is NOT a number" ; Debug
            ClipValue := "" ; Free memory
        }   

        ActiveNow := False ; Unlock Clipboard access
    }

    ActiveRecently := True

    SetTimer ActiveRecentTimer, -500 ; countdown in milliseconds everytime a hotkey calls Alter function
    return

    ActiveRecentTimer:
    ActiveRecently := False ; Expire ActiveRecently status after ActiveRecentTimer duration
    SetTimer ClipRestoreTimer, On ; start running ClipRestoreTimer
    return

    #Persistent
    SetTimer ClipRestoreTimer, 200 ; cycle in milliseconds to attempt to restore Clipboard
    SetTimer ClipRestoreTimer, Off ; Just initialize, don't start timer until a hotkey calls Alter.
    return

    ClipRestoreTimer:
    if (!ClipRestored && !ActiveNow && !ActiveRecently) ; Async / non-blocking Clipboard restoration subroutine
    {
        if (RestoreAttempts < 20) ; Maximum attempts to restore clipboard
        {
            Clipboard := ClipSaved ; Restore Clipboard contents
            ClipWait 1
            ClipSavedTemp := ClipboardAll
            if (ClipSavedTemp == ClipSaved) ; Verify success
            {
                ; MsgBox % "Successfully restored clipboard after " . RestoreAttempts . " failed attempt(s)" ; Debug
                ClipRestored := True ; Reset status
                SetTimer ClipRestoreTimer, Off
                RestoreAttempts := 0
                ClipSaved := "" ; Free memory
            }
            else
            {
                RestoreAttempts++ ; Verify failed, try again on next ClipRestoreTimer cycle
                ; MsgBox % RestoreAttempts . " failed attempt(s) to restore clipboard, Retrying" ; Debug
            }
            ClipSavedTemp := "" 
        }
        else
        {
            ; MsgBox % RestoreAttempts . " failed attempts to restore clipboard. Giving up" ; Debug
            ClipRestored := True ; Reset status
            SetTimer ClipRestoreTimer, Off
            RestoreAttempts := 0
            ClipSaved := "" ; Free memory
        }
    }
    return
}