#!/bin/sh

## Copyright (C) 2012 Kolibre
#
# This file is part of kolibre-builder.
#
# Kolibre-builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
#
# Kolibre-builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with kolibre-builder. If not, see <http://www.gnu.org/licenses/>.
#

set -e
set -x

# Find numbur of cpus on the build machine
cpus=1
if [ -f /usr/bin/lscpu ]; then
    cpus=$(lscpu | grep -e ^CPU\(s\): | cut -d ':' -f2 | tr -d ' ')
fi

#
# DEFINE VARIABLES
#

test -z "$USER" && echo "USER not set" && exit 1
make_j="-j${cpus}"
buildDir=${PWD}/build
buildStamps=${buildDir}/build.stamps
downloadDir=${PWD}/downloads
patchDir=${PWD}/patches
prefix=${PWD}/kolibre-devel
set +e
documentation=$(which doxygen)
set -e

#
# SET DEPENDENCY VERSIONS
#

#libxml2_version=2.7.8
#portaudio_version="v19_20110326"
axis2c_version=1.6.0

#
# SET DEPENDENCY VARIABLES
#

libxml2=libxml2-${libxml2_version}
libxml2src=libxml2-${libxml2_version}.tar.gz
portaudio=portaudio
portaudiosrc=pa_stable_${portaudio_version}.tgz
axis2c=axis2c-src-${axis2c_version}
axis2csrc=axis2c-src-${axis2c_version}.tar.gz

#
# HELP FUNCTIONS
#

download()
{
    wget ${1} -P ${downloadDir} --connect-timeout=5 --tries=1
}

#
# BUILD
#

export PKG_CONFIG_PATH=${prefix}/lib/pkgconfig/
export CFLAGS="-g -O2 -I${prefix}/include -pthread"
#Extra flags used on newer machines -Wno-error=unused-but-set-variable -Wno-error=uninitialized -Wno-error=maybe-uninitialized
export CXXFLAGS="-g -O2 -I${prefix}/include -pthread"
#Extra flags used on newer machines -Wno-error=unused-but-set-variable -Wno-error=uninitialized
export LDFLAGS="-L${prefix}/lib"

test -d ${buildDir} || mkdir -p ${buildDir}
test -d ${downloadDir} || mkdir -p ${downloadDir}
cd ${buildDir}

# build libxml2
if [ -n "${libxml2_version}" ] && ! grep ${libxml2src} ${buildStamps}
then
    test -f ${downloadDir}/${libxml2src} || download ftp://xmlsoft.org/libxml2/${libxml2src}
    rm -rf ${libxml2}
    tar xzvf ${downloadDir}/${libxml2src}
    cd ${libxml2}
    patch -p2 < ${patchDir}/libxml2-2.7.8_parse_doctype_internal_subset.patch
    ./configure \
        --without-python \
        --prefix=${prefix}
    make ${make_j}
    make install
    echo ${libxml2src} $(date) >> ${buildStamps}
    cd ..
fi

# build portaudio
if [ -n "${portaudio_version}" ] && ! grep ${portaudiosrc} ${buildStamps}
then
    dpkg -s libasound2-dev > /dev/null || ( echo "Please install package libasound2-dev" && exit 1 )
    test -f ${downloadDir}/${portaudiosrc} || download http://www.portaudio.com/archives/${portaudiosrc}
    rm -rf ${portaudio}
    tar zxvf ${downloadDir}/${portaudiosrc}
    cd ${portaudio}
    ./configure \
        --prefix=${prefix}
    make ${make_j}
    make install
    echo ${portaudiosrc} $(date) >> ${buildStamps}
    cd ..
fi

# build axis2c
if [ -n "${axis2c_version}" ] && ! grep ${axis2csrc} ${buildStamps}
then
    # source code was not found on any mirrors at the time of writing, thus
    # we have committed a copy of the source with this repository
    #test -f ${downloadDir}/${axis2csrc} || download http://www.eu.apache.org/dist//ws/axis2/c/1_6_0/${axis2csrc}
    rm -rf ${axis2c}
    tar xzvf ${downloadDir}/${axis2csrc}
    cd ${axis2c}
    patch -p0 < ${patchDir}/axis2c-1.6.0_curl_ssl.patch
    patch -p0 < ${patchDir}/axis2c-1.6.0_curl_useragent.patch
    patch -p0 < ${patchDir}/axis2c-1.6.0_xml_https.patch
    patch -p0 < ${patchDir}/axis2c-1.6.0_ssl_utils.patch
    patch -p0 < ${patchDir}/axis2c-1.6.0_no_neethi_test.patch

    OLD_CFLAGS="${CFLAGS}"
    export CFLAGS="${OLD_CFLAGS} -Wno-error=unused-but-set-variable -Wno-error=uninitialized -Wno-error=maybe-uninitialized"
    autoreconf -f -i
    ./configure \
        --enable-guththila=no \
        --enable-libxml2 \
        --enable-libcurl \
        --enable-openssl \
        --prefix=${prefix}
    make ${make_j}
    make install
    export CFLAGS="${OLD_CFLAGS}"
    echo ${axis2csrc} $(date) >> ${buildStamps}
    cd ..
fi

cd ..

################### build kolibre packages ########################

CWD=$PWD

# narrator
cd libkolibre/narrator
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# player
cd libkolibre/player
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# xmlreader
cd libkolibre/xmlreader
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# amis
cd libkolibre/amis
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# daisyonline
cd libkolibre/daisyonline
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# naviengine
cd libkolibre/naviengine
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix}
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# clientcode
cd libkolibre/clientcore
test -f configure || autoreconf -f -i
test -d build || mkdir build
cd build
test -f Makefile || ../configure --prefix=${prefix} --with-samples
make ${make_j} install
test -n "${documentation}" && make doxygen-doc
cd $CWD

# build messages.db using narrator utils
prompts=$PWD/libkolibre/clientcore/prompts/prompts.csv
messages=$PWD/libkolibre/clientcore/prompts/messages.csv
translations=$PWD/libkolibre/clientcore/prompts/sv/translations.csv
mkdir -p ${prefix}/share/libkolibre-narrator
output=${prefix}/share/libkolibre-narrator/messages.db
${prefix}/bin/narrator-utils -p ${prompts} -m ${messages} -t ${translations} -l sv -o ${output}
