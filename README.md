# Puppet OrchID module

This is the [Puppet][1] module for [OrchID][2]. This module configures an Ubuntu
server for OrchID.

## Requirements

This Puppet module was prepared for Ubuntu servers and was tested on Ubuntu
14.04. First install Puppet and the required puppet modules as root:

    apt-get install puppet
    puppet module install puppetlabs-apache
    puppet module install puppetlabs-apt
    puppet module install stankevich-python

OrchID depends on the [ImgPheno][3] and [NBClassify][2] Python packages. These
must be installed before proceeding.

OrchID can be found in the [NBClassify][2] repository. For convenience, the
repository also contains the Django site in the `html/` directory. On a
production server, make sure to change the following settings in
`html/webapp/settings.py`:

    SECRET_KEY = 'RANDOM_STRING_HERE'
    DEBUG = False
    TEMPLATE_DEBUG = False
    ALLOWED_HOSTS = ['orchid.example.com']

## Installation

To install this Puppet module, clone this repository in `/etc/puppet/modules/`
and rename the directory to "orchid" (i.e. `mv puppet-orchid orchid`).

## Usage

Put the following code in a Puppet manifest (e.g. `orchid.pp` or `site.pp`):

    class { 'orchid' :
        domain => 'orchid.example.com',
        doc_root => '/var/www/orchid',
        site_root => '/opt/nbclassify/html',
        site_name => 'webapp',
        venv_path => '/opt/nbclassify/html/env',
        imgpheno => '/opt/imgpheno',
        nbclassify => '/opt/nbclassify/nbclassify',
    }

Change the arguments as required (see the list of parameters below). In the
above example, `/opt/nbclassify/` is the location where the NBClassify
repository was cloned. Notice that the NBClassify package is not the root of
that repository, but in a subdirectory `nbclassify`. ImgPheno was cloned to
`/opt/imgpheno/`. The OrchID site is located at `/opt/nbclassify/html`.

Finally, trigger the Puppet run as root:

    puppet apply orchid.pp

OrchID should now be accessible on the provided domain.

### Class parameters

    $domain::         Specifies the server name that will be used for the virtual
                      host.
    $doc_root::       Specifies the virtual host's document root. $site_root may
                      not be contained in this directory.
    $site_root::      Specifies the path to the root of the existing Django site.
                      The Django site must be created manually before triggering
                      Puppet with this class.
    $site_name::      Specifies the name of the existing Django site. This is the
                      name of the directory containing the site's settings.py.
    $venv_path::      Specifies the path to the Python virtualenv directory where
                      all requirements will be installed.

[1]: https://puppetlabs.com/puppet/what-is-puppet
[2]: https://github.com/naturalis/nbclassify
[3]: https://github.com/naturalis/imgpheno
