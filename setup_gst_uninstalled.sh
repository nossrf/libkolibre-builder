#!/bin/sh

# Find numbur of cpus on the build machine
cpus=1
if [ -f /usr/bin/lscpu ]; then
    cpus=$(lscpu | grep -e ^CPU\(s\): | cut -d ':' -f2 | tr -d ' ')
fi

gst_uninstalled=gst-git
fluendo_version=0.10.22
fluendo=gst-fluendo-mp3-${fluendo_version}
fluendosrc=gst-fluendo-mp3-${fluendo_version}.tar.gz


build_gst_base=$(pwd)
download_uninstalled(){
    wget http://cgit.freedesktop.org/gstreamer/gstreamer/plain/scripts/gst-uninstalled -O $build_gst/$gst_uninstalled
    chmod u+x $build_gst/$gst_uninstalled

    #Change build path
    sed -i "s/MYGST=\$HOME\/gst/MYGST=$(echo $build_gst | sed -e 's/\//\\\//g')/g" $build_gst/$gst_uninstalled
    #Dont change dir
    sed -i "s/cd \$GST//g" $build_gst/$gst_uninstalled
    #Search for fluendo in compilepath
    sed -i "142 i :\$GST/$fluendo/src/.libs\\\\" $build_gst/$gst_uninstalled
}

setup_uninstalled(){
    mkdir -p build/gst/
    build_gst="$build_gst_base/build/gst"

    if [ ! -e "$build_gst/$gst_uninstalled" ]; then
        download_uninstalled
    fi   
 
    mkdir -p $build_gst/git
    echo "Successfully setup gstreamer-uninstalled environment. Remember to exit :)"
    $build_gst/$gst_uninstalled
}

# build fluendo mp3
build_fluendo(){
if [ ! -d "${fluendo}" ]; then
    #dpkg -s libasound2-dev > /dev/null || ( echo "Please install package libasound2-dev" && exit 1 )
    test -f ${fluendosrc} || wget http://core.fluendo.com/gstreamer/src/gst-fluendo-mp3/${fluendosrc}
    tar zxvf ${fluendosrc}
    cd ${fluendo}
    ./autogen.sh
    make ${make_j}
    cd ..
fi
}

compile() {
    PACKAGES="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad"
    cd $build_gst_base/build/gst/git

    for package in $PACKAGES; do
        if [ ! -d $package ]; then
        git clone git://anongit.freedesktop.org/gstreamer/$package -b 0.10
        cd $package
        ./autogen.sh
        make -j$cpus
        cd ..
        else
            echo "Package $package already configured"
        fi
    done

    build_fluendo
}

if [ -z "$GST_PLUGIN_SCANNER" ]; then
    setup_uninstalled
else
    echo 'gstreamer-uninstalled environment already setup!'
    compile
fi
