# autohotkey-alter-numeric
Alter numeric values in text fields of any application using clipboard manipulation. Increment or decrement by any value or order of magnitude, or perform arbitrary maths functions. Preserves clipboard contents using aggressive async state management. Written in AutoHotkey_L (1.1.32.00) for Microsoft Windows. https://www.autohotkey.com

I have taken a less conventional approach to Clipboard exploitation and management that strongly favors performance and low response times to allow for fast successive key presses and key repeats. I have mainly tested this with Unity Editor 2020+ and SideFX Houdini 18+ on Windows 10 but it should work with many other applications that have numerical text input fields. You may need to adjust the constants and expressions / commands below to suit your application(s) needs and tune reliability. Having said that, I performed limited testing, but I am not sure of the exact reliability of my async clipboard restoration, as reliability and simplicity is not the goal here. Speed is the primary focus. So if making 100% sure you never lose the contents of your clipboard is of a high importance, this is not for you. I suggest seeking well established examples with simpler methods and higher Sleep / delayed response times. 

However, if you value being able to perform maths operations and transformations on parameter / property sheets in GUI applications in real-time like an absolute maniac on your keyboard, and retaining clipboard contents is just nice to have most of the time, then this may be for you.

There are also user32.dll based clipboard "paste wait" methods that are more or less broken in 64-bit Windows as far as I and anyone else in public forums can seem to tell. There is also the forthcoming AHK v2's Dynarun method, but v2 is still in an early Alpha state as of this writing, and I figured others might benefit from a solution made with AHK v1.

You will likely need to modify the key shortcuts as I use non standard function key codes that I've mapped to macro keys on my keyboard.

https://user-images.githubusercontent.com/15337230/117635105-5eb0e880-b134-11eb-94f2-0a27d389ca81.mp4
