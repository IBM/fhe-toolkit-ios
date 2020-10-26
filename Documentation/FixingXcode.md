Notes on what is going on with the ios toolkit

- I can run the toolkit on xcode 12 with dependency libraries that are built using the Xcode 11 (11.7) clang

- If I run the setup script using the Xcode 11.7 commandline tools, everything will run, and I can build on Xcode 12.  As long as Valid_Architectures is removed as a Macro setting.  The conversion from Xcode 11 to Xcode 12 will add this automatically.

Steps to get this to run...

1. Install Xcode 12 from the AppStore
2. Download Xcode 11.7 from here [https://developer.apple.com/download/more/](https://developer.apple.com/download/more/)
3. 