#MIT License
#
#Copyright (c) 2020 International Business Machines
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

#!/bin/sh
set -x
echo " — — — — — — — — — — Building Dependencies Script Started — — — — — — — — — — "

MIN_IOS="10.0"
MIN_WATCHOS="2.0"
MIN_TVOS=$MIN_IOS
MIN_MACOS="10.10"
IPHONEOS=iphoneos
IPHONESIMULATOR=iphonesimulator
WATCHOS=watchos
WATCHSIMULATOR=watchsimulator
TVOS=appletvos
TVSIMULATOR=appletvsimulator
MACOS=macosx
LOGICALCPU_MAX=`sysctl -n hw.logicalcpu_max`
GMP_DIR="`pwd`/gmp"
NTL_VERSION="11.4.1"
GMP_VERSION="6.1.2"

change_submodules() 
{
    git submodule update --init --recursive
}

check_cmake() 
{
    install_cmake()
    {
        echo "installing cmake"
        curl -OL https://github.com/Kitware/CMake/releases/download/v3.17.1/cmake-3.17.1-Darwin-x86_64.tar.gz
        tar -xzf cmake-3.17.1-Darwin-x86_64.tar.gz
        sudo mv cmake-3.17.1-Darwin-x86_64/CMake.app /Applications
        sudo /Applications/CMake.app/Contents/bin/cmake-gui --install

    }

    if hash cmake 2>/dev/null; then
        echo "WE HAVE CMAKE GO ON"
    else
        #we have to install cmake
        echo "we need to install cmake"
        install_cmake
    fi
}

version_min_flag()
{
    PLATFORM=$1
    FLAG=""
    if [[ $PLATFORM = $IPHONEOS ]]; then
        FLAG="-miphoneos-version-min=${MIN_IOS}"
    elif [[ $PLATFORM = $IPHONESIMULATOR ]]; then
        FLAG="-mios-simulator-version-min=${MIN_IOS}"
    elif [[ $PLATFORM = $WATCHOS ]]; then
        FLAG="-mwatchos-version-min=${MIN_WATCHOS}"
    elif [[ $PLATFORM = $WATCHSIMULATOR ]]; then
        FLAG="-mwatchos-simulator-version-min=${MIN_WATCHOS}"
    elif [[ $PLATFORM = $TVOS ]]; then
        FLAG="-mtvos-version-min=${MIN_TVOS}"
    elif [[ $PLATFORM = $TVSIMULATOR ]]; then
        FLAG="-mtvos-simulator-version-min=${MIN_TVOS}"
    elif [[ $PLATFORM = $MACOS ]]; then
        FLAG="-mmacosx-version-min=${MIN_MACOS}"
    fi
    echo $FLAG
}
prepare()
{
    download_gmp()
    {
        CURRENT_DIR=`pwd`
        if [ ! -s ${CURRENT_DIR}/gmp-${GMP_VERSION}.tar.bz2 ]; then
            curl -L -o ${CURRENT_DIR}/gmp-${GMP_VERSION}.tar.bz2 https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2
        fi
        rm -rf gmp
        tar xfj "gmp-${GMP_VERSION}.tar.bz2"
        mv gmp-${GMP_VERSION} gmp
        cd gmp
    }
    download_ntl()
    {
        CURRENT_DIR=`pwd`
        if [ ! -s ${CURRENT_DIR}/ntl-${NTL_VERSION}.tar.gz ]; then
            curl -L -o ${CURRENT_DIR}/ntl-${NTL_VERSION}.tar https://www.shoup.net/ntl/ntl-${NTL_VERSION}.tar.gz
        fi
        tar xvf "ntl-${NTL_VERSION}.tar"
    }
    download_ntl
    download_gmp
}

build_gmp()
{
   
    PLATFORM=$1
    ARCH=$2
    SDK=`xcrun --sdk $PLATFORM --show-sdk-path`
    PLATFORM_PATH=`xcrun --sdk $PLATFORM --show-sdk-platform-path`
    CLANG=`xcrun --sdk $PLATFORM --find clang`
    CURRENT_DIR=`pwd`
    DEVELOPER=`xcode-select --print-path`
    export PATH="${PLATFORM_PATH}/Developer/usr/bin:${DEVELOPER}/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    mkdir "${CURRENT_DIR}/../gmplib-so-${PLATFORM}-${ARCH}"
   CFLAGS="-arch ${ARCH} --sysroot=${SDK}"
    EXTRA_FLAGS="$(version_min_flag $PLATFORM)"
    CCARGS="${CLANG} ${CFLAGS}"
    CPPFLAGSARGS="${CFLAGS} ${EXTRA_FLAGS}"
    #CONFIGURESCRIPT="gmp_configure_script.sh"
    #cat >"$CONFIGURESCRIPT" << EOF

    ./configure CC="$CCARGS" CPPFLAGS="$CPPFLAGSARGS" --host=${ARCH}-apple-darwin_sim --disable-assembly --disable-shared --prefix="${CURRENT_DIR}/../gmplib-so-${PLATFORM}-${ARCH}"

    make -j $LOGICALCPU_MAX &> "${CURRENT_DIR}/gmplib-so-${PLATFORM}-${ARCH}-build.log"
    make install &> "${CURRENT_DIR}/gmplib-so-${PLATFORM}-${ARCH}-install.log"
    rm "${CURRENT_DIR}/../gmplib-so-${PLATFORM}-${ARCH}/lib/libgmp.10.dylib"
    rm "${CURRENT_DIR}/../gmp-${GMP_VERSION}.tar.bz2"
    cd ../
}

build_ntl()
{
    CURRENT_DIR=`pwd`
    patch_ntl()
    {
         CURRENT_DIR=`pwd`
         echo "where am I ${CURRENT_DIR}"
         patch -u ntl-${NTL_VERSION}/src/DoConfig -i patch_files_ntl/DoConfig.patch.txt
         patch -u ntl-${NTL_VERSION}/src/mfile -i patch_files_ntl/mfile.patch.txt
     }
    patch_ntl
    PLATFORM=$1
    ARCH=$2
    
    SDK=`xcrun --sdk $PLATFORM --show-sdk-path`
    
    mkdir ntl
    mkdir ntl/libs
    cd ntl-${NTL_VERSION}
    cd src

    ./configure CXX=clang++ CXXFLAGS_="-fembed-bitcode -stdlib=libc++  -arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=10.0"  NTL_THREADS=on NATIVE=off TUNE=generic NTL_GMP_LIP=on PREFIX="${CURRENT_DIR}/ntl" GMP_PREFIX="${CURRENT_DIR}/gmplib-so-${PLATFORM}-${ARCH}"
    make -j
    
    cp -R "${CURRENT_DIR}/ntl-${NTL_VERSION}/include" "${CURRENT_DIR}/ntl" 
    cp "${CURRENT_DIR}/ntl-${NTL_VERSION}/src/ntl.a" "${CURRENT_DIR}/ntl/libs/ntl.a"
    rm "${CURRENT_DIR}/ntl-${NTL_VERSION}.tar"
    cd ../../
}

build_ntl_arm()
{
    CURRENT_DIR=`pwd`
    patch_ntl()
    {
         CURRENT_DIR=`pwd`
         echo "where am I ${CURRENT_DIR}"
         patch -u ntl-${NTL_VERSION}/src/DoConfig -i patch_files_ntl/DoConfig.patch.txt
         patch -u ntl-${NTL_VERSION}/src/mfile -i patch_files_ntl/mfile.patch.txt
     }
    patch_ntl
    PLATFORM=$1
    ARCH=$2
    
    SDK=`xcrun --sdk $PLATFORM --show-sdk-path`
    
    mkdir "ntl-${PLATFORM}-${ARCH}"
    mkdir "ntl-${PLATFORM}-${ARCH}/libs"
    cd ntl-${NTL_VERSION}
    cd src

    ./configure CXX=clang++ CXXFLAGS_="-fembed-bitcode -stdlib=libc++  -arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=10.0"  NTL_THREADS=on NATIVE=off TUNE=generic NTL_GMP_LIP=on PREFIX="${CURRENT_DIR}/ntl" GMP_PREFIX="${CURRENT_DIR}/gmplib-so-${PLATFORM}-${ARCH}"
    make -j
    
    cp -R "${CURRENT_DIR}/ntl-${NTL_VERSION}/include" "${CURRENT_DIR}/ntl-${PLATFORM}-${ARCH}/include" 
    cp "${CURRENT_DIR}/ntl-${NTL_VERSION}/src/ntl.a" "${CURRENT_DIR}/ntl-${PLATFORM}-${ARCH}/libs/ntl.a"
    rm "${CURRENT_DIR}/ntl-${NTL_VERSION}.tar"
    cd ../../
}

build_helib() 
{
    PLATFORM=$1
    ARCH=$2
    CURRENT_DIR=`pwd`
    DEPEND_DIR="${CURRENT_DIR}"
    cp "${CURRENT_DIR}/Helib_install/CMakeLists.txt" "${CURRENT_DIR}/HElib"
    cd "${CURRENT_DIR}/HElib"
    cmake -S. -B../HElib_iOS -GXcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.2 \
    -DCMAKE_INSTALL_PREFIX=`pwd`/_install \
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
    -DCMAKE_IOS_INSTALL_COMBINED=YES \
    -DGMP_DIR="${DEPEND_DIR}/gmp" \
    -DGMP_HEADERS="${DEPEND_DIR}/gmp/include" \
    -DGMP_LIB="${DEPEND_DIR}/gmp/lib/libgmp.a" \
    -DNTL_INCLUDE_PATHS="${DEPEND_DIR}/ntl/include" \
        -DNTL_LIB="${DEPEND_DIR}/ntl/lib/ntl.a" \
        -DNTL_DIR="${DEPEND_DIR}/ntl/include"
}

build_all()
{
    SUFFIX=$1
    BUILD_IN=$2
    
    build_gmp "${IPHONESIMULATOR}" "x86_64"
    build_ntl "${IPHONESIMULATOR}" "x86_64"
    #build_ntl_arm "${IPHONEOS}" "arm64"
    #build_ntl_arm "${IPHONESIMULATOR}" "x86_64"
    build_helib "${IPHONESIMULATOR}" "x86_64"
}

change_submodules
check_cmake
prepare
build_all "ios" "${IPHONESIMULATOR};|x86_64"
echo " — — — — — — — — — — Building Dependencies Script Ended — — — — — — — — — — "

