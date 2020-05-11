# FHE-Toolkit-iOS

----------------------------------------------------------------------------
IBM Fully Homomorphic Encryption Toolkit For iOS
----------------------------------------------------------------------------

This source code is the packaged XCode project and resources needed to build the open source <a href="https://github.com/homenc/HElib/">HELib</a> <a href="https://en.wikipedia.org/wiki/Homomorphic_encryption">Fully Homomorphic Encryption</a> library on an iPhone Simulator. 

----------------------------------------------------------------------------
About Xcode Projects
----------------------------------------------------------------------------

If you are a developer interested in Homomorphic Encryption and you develop for iOS, this project will help you get started with a pre-configured [Xcode](https://developer.apple.com/xcode/) Project that can save you time. If you are new to Xcode, an Xcode project is a directory structure for all the resources needed to build one or more apps using the Xcode IDE from Apple.  You can install Xcode directly through the App Store. 

The contents of this Xcode project includes the pre-determined compilation procedure and the required dependency relationships between source code modules. Typically an Xcode project contains one or more build targets, which specify the compilation procedure for the final executable or library products. This project comes complete with default build settings for HELib as well as the two external dependencies required by HELib, namely [The GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org/) and [NTL Lib](https://www.shoup.net/ntl/) which is a number theoretic library.

The targets of the project are:
	•	Privacy Preserving Search (sample app)
	•	helib Library





--------------------------------------------
Source Code Overview:
--------------------------------------------

The code base is split up into a few major components.  Upon initial installation, a script is needed to download and compile the source code and its dependencies.  This code is then accessed through the Xcode workspace, `fhe-toolkit-ios.xcworkspace`.  Always use the workspace when trying to work with any of these components. 

* The Helib source code is a copy of the public open source repo of [HElib](https://github.com/homenc/HElib).  The files have been compiled into a static library and linked to the `fhe-toolkit-ios` project file.  This is done through a shared workspace.  All work should be done through the `fhe-toolkit-ios.xcworkspace` file.

* The `include/helib` directory contains all of the .h files that are a copy of the public open source repo of [HElib](https://github.com/homenc/HElib).  None of these files have been modified from the original files from that repo, but they need to be included in the Xcode project in order to build.  In the Xcode project, under the target, under `Build Settings`, there is a path that links to these files under `Header Search Paths`.  The current path is a relative path to the files from your system directory.  They currently reside in `dependencies/HElib/include`.  If you change the location of these files it will be neccessary to update this path.

* The Helib library has two dependencies from other open source libraries.  They are built when the `setup.sh` script is run for the first time.  They currently build for the x86_64 ARCHITECTURE and get added to the `dependencies` folder.  Nothing needs to be done with them, but they are linked as relative paths on the target, in `Build Settings` under `Library Search Paths`, for the .a files, and `Header Search Paths` for the .h files.  Again if you alter the location of these files, you will need to update these paths accordingly.

    * ntl                              -   
    * gmplib-so-iphonesimulator-x86_64 -

--------------------------------------------
fhe-toolkit-ios.xcworkspace
--------------------------------------------
A workspace is an Xcode document that groups projects and other documents so you can work on them together. A workspace can contain any number of Xcode projects, plus any other files you want to include.  

This workspace contains the iOS sample code for running in the iPhone Simulator as well as the helib target for building the helib.a static library.




--------------------------------------------
fhe-toolkit-ios.xcodeproj
--------------------------------------------
This directory contains the project files describing the XCode build environment. 

* project.xcworkspace	- 
* xcshareddata/xcschemes - 	
* project.pbxproj -

--------------------------------------------
fhe-toolkit-ios
--------------------------------------------

This is the Xcode Directory that contains all of the files that are neccessary to build the iOS target.  The Helib files are imported into the `CapitalDetailViewController.mm` 

* Assets.xcassets	- 
* Base.lproj -
* AppDelegate.h	-
* AppDelegate.m	-
* Info.plist	-
* Morphic.entitlements -	
* CountryCapitalTableViewController.h
* CountryCapitalTableViewController.m
* CountryData.h
* CountryData.m
* data.json
* main.m	-	





--------------------------------------------
Compiling and Running the XCode Project
--------------------------------------------

If you want to dive right in and get started using the SDK, please see the [Getting Started Document](GettingStarted.md).


