What is Kolibre?
---------------------------------
Kolibre is a Finnish non-profit association whose purpose is to promote
information systems that aid people with reading disabilities. The software
which Kolibre develops is published under open source and made available to all
stakeholders at github.com/kolibre.

Kolibre is committed to broad cooperation between organizations, businesses and
individuals around the innovative development of custom information systems for
people with different needs. More information about Kolibres activities, association 
membership and contact information can be found at http://www.kolibre.org/


What is libkolibre-builder?
---------------------------------
Libkolibre-builder is a repository containing instructions and build scripts for
building the libkolibre libraries and sample client and various platforms. It
also functions as a developing framework that developers can use when adding new
features or fixing bugs in the libraries.


Documentation
---------------------------------
Kolibre client developer documentation is available at 
https://github.com/kolibre/libkolibre-builder/wiki


Build instructions for Linux
---------------------------------

Install general build tools

    $ sudo apt-get install build-essential autotools-dev autoconf autoconf-archive libtool pkg-config

Install libkolibre build dependencies

    $ sudo apt-get install liblog4cxx10-dev libvorbis-dev libsoundtouch1-dev espeak \
    sox vorbis-tools libsqlite3-dev libboost-signals-dev libboost-regex-dev \
    libgstreamer-plugins-base0.10-dev libcurl4-openssl-dev libtidy-dev libxml2-dev \
    socat libasound2-dev

Install gstreamer runtime dependencies

    $ sudo apt-get install gstreamer0.10-plugins-good gstreamer0.10-plugins-bad \
    gstreamer0.10-fluendo-mp3 gstreamer0.10-alsa

Checkout the submodules

    $ git submodule init && git submodule update

Run the build script

    $ ./build_linux_sdk.sh


Licensing
---------------------------------
Copyright (C) 2012 Kolibre

This file is part of libkolibre-builder.

Libkolibre-builder is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 2.1 of the License, or
(at your option) any later version.

Libkolibre-builder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with libkolibre-builder. If not, see <http://www.gnu.org/licenses/>.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/6d0b0d8cebf269e4f560f54b94609b8a "githalytics.com")](http://githalytics.com/kolibre/libkolibre-builder)
