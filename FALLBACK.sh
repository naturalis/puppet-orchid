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

# Domain name
domain='orch-id-dev.naturalis.nl'

# XXX is this necessary?
doc_root='/var/www/orchid'

# Basic locations
imgpheno='/opt/imgpheno'
site_root='/opt/nbclassify/html'
venv_path='/opt/nbclassify/html/env'
nbclassify='/opt/nbclassify/nbclassify'
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

# Make the doc root and media path
for dir in "${doc_root} ${media_path}"; do
    if [ ! -d "${dir}" ]; then
        mkdir $dir
        chown 'www-data' $dir
        chgrp 'www-data' $dir
    fi
done

# Configure the site root
chmod 'g+rwx' $site_root
chgrp 'www-data' $site_root
if [ ! -d "${site_root}/${site_name}/static/" ]; then
    mkdir "${site_root}/${site_name}/static/"
fi

# XXX is this necessary?
ln -s '/usr/lib/python2.7/dist-packages/django/contrib/admin/static/admin' $static_admin_path
ln -s '/usr/lib/python2.7/dist-packages/rest_framework/static/rest_framework' $static_rest_path

# Enable wsgi
a2enmod wsgi

# Download and enable virtual host
cd /etc/apache2/sites-available && wget https://raw.githubusercontent.com/naturalis/puppet-orchid/master/orch-id.conf
a2ensite orch-id

#############################################################################
# Update PATH for unprivileged user
exit    
echo 'export PATH=$PATH:/opt/nbclassify/nbclassify/scripts/' >> ~/.profile
