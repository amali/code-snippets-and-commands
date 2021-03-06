#!/bin/bash

sudo apt-get update 
sudo apt-get upgrade 
Python 2.7
# if needed
sudo apt install python-pip
pip install --upgrade pip

sudo -H pip install tornado
sudo -H pip install ws4py==0.3.2
sudo -H pip install pyyaml

sudo apt install python-gobject
sudo apt install python-dbus

# docker version (I have never used it)
https://github.com/jcsilva/docker-kaldi-gstreamer-server

#################################################
##################### kaldi #####################
#################################################
git clone https://github.com/kaldi-asr/kaldi.git

cd kaldi/tools/
extras/check_dependencies.sh
# if needed
sudo apt-get install  zlib1g-dev make automake autoconf subversion
sudo apt-get install g++
sudo apt-get install  libtool
sudo apt-get install libatlas3-base

# run make; it will take time 
make [-j 8]

cd kaldi/src/
./configure --shared
To compile: make clean -j; make depend -j; make -j

#################################################
########  gst-kaldi-nnet2-online  ###############
#################################################
git clone https://github.com/alumae/gst-kaldi-nnet2-online.git
cd gst-kaldi-nnet2-online/src
# edit Makefile
vim Makefile
KALDI_ROOT?=/home/disooqi/kaldi

sudo apt-get install gstreamer1.0-plugins-bad  gstreamer1.0-plugins-base gstreamer1.0-plugins-good  gstreamer1.0-pulseaudio  gstreamer1.0-plugins-ugly  gstreamer1.0-tools libgstreamer1.0-dev
sudo apt-get install libjansson-dev

# and then save and run
make depend
# and run
KALDI_ROOT=/home/disooqi/kaldi make

wget -O /tmp/model.tar.gz https://qcristore.blob.core.windows.net/public/asrlive/models/arabic/nnet3sac.tar.gz

# untar it to /opt/model
sudo mkdir -m 777 /opt/model
tar xzvf /tmp/model.tar.gz -C /opt/model

# In the worker side
# out-dir: /home/qcri/spool/asr/nnet3sac
sudo mkdir -p -m 777 /var/spool/asr/nnet3sac

#################################################
########  kaldi-gstreamer-server  ###############
#################################################
git clone https://github.com/disooqi/kaldi-gstreamer-server.git

Running the server
====================
screen -S kserver
cd kaldi-gstreamer-server
python kaldigstserver/master_server.py --port=8888

C-a d

Running a worker
==================
screen -S w01
# export GST_PLUGIN_PATH=~/kaldi/src/gst-plugin
# GST_PLUGIN_PATH=. gst-inspect-1.0 kaldinnet2onlinedecoder
export GST_PLUGIN_PATH=/home/disooqi/gst-kaldi-nnet2-online/src

cd kaldi-gstreamer-server
python kaldigstserver/worker.py -u ws://localhost:8888/worker/ws/speech -c /opt/model/model.yaml


#############################################
            
#############################################
https://letsencrypt.org/getting-started/
https://certbot.eff.org/#ubuntuxenial-apache
## Please follow the link: 
# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
sudo ufw allow 8888

### http://localhost is treated as a secure origin, so if you're able to run your server from localhost, you should 
### be able to test the feature on that server.


#############################################
############## In the client side ###########
#############################################
git clone https://github.com/disooqi/alt-hackathon-docs
cd alt-hackathon-docs/asr/examples/static-webapp-example

# edit index.js and assign to ASR_SERVER variable
var ASR_SERVER = "qatslive4520.cloudapp.net:8888";

# start a local server
python -m SimpleHTTPServer 2018

###############################################
###########   Android Client
###############################################
# https://github.com/Kaljurand/K6nele
# https://askubuntu.com/questions/318246/complete-installation-guide-for-android-sdk-adt-bundle-on-ubuntu/466302
# https://developer.android.com/studio/install.html
curl -s "https://get.sdkman.io" | bash
sdk install gradle 4.6
export ANDROID_HOME=${HOME}/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
gradle assemble
# AND THEN 
# https://github.com/Kaljurand/K6nele/issues/38
# https://github.com/jcsilva/docker-kaldi-gstreamer-server
# https://stackoverflow.com/questions/9997720/how-to-register-a-custom-speech-recognition-service
# https://gist.github.com/aryeharmon/85673d69b07c5b7061c38ac4323f409c
