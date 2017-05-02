#!/bin/bash

# This is presented here as a shell script but it should really be seen as a
# step-by-step guide of what needs to happen to install all the pre-requisites
# for naturalis/img-classify-all

# all following steps need to be taken by root
sudo su

# since we target Ubuntu 16.04LTS do as much as possible with apt-get
apt-get update

# non-python pre-requisites
apt-get install git build-essential ca-certificates libopencv-dev apache2

#############################################################################
# python packages
apt-get install \
    python-setuptools \
    python-dev \
    python-pip \
    python-numpy \
    python-opencv \
    python-pyfann \
    python-sklearn \
    python-yaml \
    python-flickrapi \
    python-scipy \
    python-sqlalchemy \
    python-django \
    python-djangorestframework \
    python-sorl-thumbnail

# install imgpheno as 'editable'. The general idea is that this could
# therefore be updated from github
cd /opt
git clone https://github.com/naturalis/imgpheno.git
cd imgpheno
pip install -e .
cd ../

# same thing for nbclassify
git clone https://github.com/naturalis/nbclassify.git
cd nbclassify/nbclassify
pip install -e .

#############################################################################


#############################################################################
# update PATH for unprivileged user
exit    
echo 'export PATH=$PATH:/opt/nbclassify/nbclassify/scripts/' >> ~/.profile
