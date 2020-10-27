# Xcode Workaround

We are currently experiencing an issue in Xcode 12 that does not let us build some of the dependencies we need to run HELib on the proper iOS Architectures.  

The easiest way to overcome this is to build and run everything with a previous version of Xcode.  Xcode 11.7 builds and runs everything correctly, so you can download that from [Apple's Download]([https://developer.apple.com/download/more/](https://developer.apple.com/download/more/)) page, and Install to your `Applications` Directory.

If you need to use Xcode 12 or above to build, then you can run the toolkit in Xcode 12, but build the dependency libraries using the Command Line Tools from Xcode 11.7.

The following steps explain how to do this:

## Step 1: Install Xcode 12

Install Xcode 12 or the latest version from the
[AppStore](https://apps.apple.com/us/app/xcode/id497799835?mt=12).

[<img src="/Documentation/Images/Xcode_Icon.png" width="200"/>](/Documentation/Images/Xcode_Icon.png)

## Step 2: Download & Install Xcode 11.7

Download and install Xcode 11.7 from Apple's Download page. [https://developer.apple.com/download/more/](https://developer.apple.com/download/more/).

[<img src="/Documentation/Images/FX_Step_2.png" width="506"/>](/Documentation/Images/FX_Step_2.png)


Install Xcode 11.7 into your `/Applications/Xcode11.7.app` directory and rename it `Xcode11.7`.  If you don't rename it you will override your existing Xcode version. When you name it make sure you don't add any spaces in the name as spaces tend to break the compiling of dependencies. 

[<img src="/Documentation/Images/FX_Step_3.png" width="704"/>](/Documentation/Images/FX_Step_3.png) 

## Step 3: Switch Command Line Tools
Open your Terminal app `/Applications/Utilities/Terminal.app`, and switch your Xcode Command Line Tools to be Xcode11.7 by entering the following...

        sudo xcode-select --switch /Applications/Xcode11.7.app     
     

## Back to the Getting Started Guide

Continue to Step 2 of the [Getting Started Guide](/GettingStarted.md) and follow the instructions as noted.
   
