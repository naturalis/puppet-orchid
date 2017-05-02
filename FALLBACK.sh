#!/bin/bash

# This is presented here as a shell script but it should really be seen as a
# step-by-step guide of what needs to happen to install all the pre-requisites
# for naturalis/img-classify-all

# all following steps need to be taken by root
sudo su

# since we target Ubuntu 16.04LTS do as much as possible with apt-get
apt-get update

# non-python pre-requisites
apt-get install \
    git \
    build-essential \
    ca-certificates \
    libopencv-dev \
    apache2 \
    libapache2-mod-wsgi

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
# configure apache2
# domain name and basic paths
domain='orch-id-dev.naturalis.nl'
doc_root='/var/www/orchid'
site_root='/opt/nbclassify/html'
site_name='webapp'
venv_path='/opt/nbclassify/html/env'
imgpheno='/opt/imgpheno'
nbclassify='/opt/nbclassify/nbclassify'

# additional server paths
media_path="${site_root}/media/"
static_admin_path="${site_root}/${site_name}/static/admin"
static_rest_path="${site_root}/${site_name}/static/rest_framework/"
static_path="${site_root}/orchid/static/"

# create the SQLite database for OrchID.
cd $site_root && python manage.py migrate
chmod 'g+rw' "${site_root}/db.sqlite3"
chgrp 'www-data' "${site_root}/db.sqlite3"

# make the doc root and media path
for dir in "${doc_root} ${media_path}"; do
    if [ ! -d "${dir}" ]; then
        mkdir $dir
        chown 'www-data' $dir
        chgrp 'www-data' $dir
    fi
done

# configure the site root
chmod 'g+rwx' $site_root
chgrp 'www-data' $site_root
if [ ! -d "${site_root}/${site_name}/static/" ]; then
    mkdir "${site_root}/${site_name}/static/"
fi

# make symlinks
ln -s '/usr/lib/python2.7/dist-packages/django/contrib/admin/static/admin' $static_admin_path
ln -s '/usr/lib/python2.7/dist-packages/rest_framework/static/rest_framework' $static_rest_path

# enable wsgi
a2enmod wsgi

#############################################################################
# update PATH for unprivileged user
exit    
echo 'export PATH=$PATH:/opt/nbclassify/nbclassify/scripts/' >> ~/.profile
