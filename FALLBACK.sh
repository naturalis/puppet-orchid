#!/bin/bash

# This is presented here as a shell script but it should really be seen as a
# step-by-step guide of what needs to happen to install all the pre-requisites
# for naturalis/img-classify-all

# All following steps need to be taken by root, to which we login here.
sudo su

# Since we target Ubuntu 16.04LTS we can use apt-get, which we refresh here.
apt-get update

# Install non-python pre-requisites
apt-get install \
    git \
    build-essential \
    ca-certificates \
    libopencv-dev \
    apache2 \
    libapache2-mod-wsgi

#############################################################################
# CONFIGURE PYTHON
# Install python packages using apt-get. This means they are all system-wide.
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

# Install imgpheno as 'editable'. The general idea is that this could
# therefore be updated from github later on, with 'git pull'
cd /opt
git clone https://github.com/naturalis/imgpheno.git
cd imgpheno
pip install -e .
cd ../

# Same thing for nbclassify
git clone https://github.com/naturalis/nbclassify.git
cd nbclassify/nbclassify
pip install -e .

#############################################################################
# CONFIGURE APACHE2

# Are these necessary?
#domain='orch-id-dev.naturalis.nl'
#doc_root='/var/www/orchid'
#venv_path='/opt/nbclassify/html/env'
#imgpheno='/opt/imgpheno'
#nbclassify='/opt/nbclassify/nbclassify'

# Basic locations
site_root='/opt/nbclassify/html'
site_name='webapp'

# Additional server paths
media_path="${site_root}/media/"
static_admin_path="${site_root}/${site_name}/static/admin"
static_rest_path="${site_root}/${site_name}/static/rest_framework"
static_path="${site_root}/orchid/static/"

# Create the SQLite database for OrchID.
cd $site_root && python manage.py migrate
chmod 'g+rw' "${site_root}/db.sqlite3"
chgrp 'www-data' "${site_root}/db.sqlite3"

# Make the media path (for uploads)
if [ ! -d "${media_path}" ]; then
    mkdir ${media_path}
    chown 'www-data' ${media_path}
    chgrp 'www-data' ${media_path}
fi

# Configure the site root
chmod 'g+rwx' $site_root
chgrp 'www-data' $site_root
if [ ! -d "${site_root}/${site_name}/static/" ]; then
    mkdir "${site_root}/${site_name}/static/"
fi

# Symlink static assets for admin and REST UI elements
ln -s '/usr/lib/python2.7/dist-packages/django/contrib/admin/static/admin' $static_admin_path
ln -s '/usr/lib/python2.7/dist-packages/rest_framework/static/rest_framework' $static_rest_path

# Set up wsgi and enable virtual host
a2enmod wsgi
cd /etc/apache2/sites-available && wget https://raw.githubusercontent.com/naturalis/puppet-orchid/master/orch-id.conf
a2ensite orch-id
service apache2 reload

#############################################################################
# Update PATH for unprivileged user
exit    
echo 'export PATH=$PATH:/opt/nbclassify/nbclassify/scripts/' >> ~/.profile
