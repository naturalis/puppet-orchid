# = Class: orchid
#
# This module configures an Ubuntu server for serving OrchID.
#
# == Parameters:
#
# $domain::         Specifies the server name that will be used for the virtual
#                   host.
# $doc_root::       Specifies the virtual host's document root. $site_root may
#                   not be contained in this directory.
# $site_root::      Specifies the path to the root of the existing Django site.
#                   The Django site must be created manually before triggering
#                   Puppet with this class.
# $site_name::      Specifies the name of the existing Django site. This is the
#                   name of the directory containing the site's settings.py.
# $venv_path::      Specifies the path to the Python virtualenv directory where
#                   all requirements will be installed.
# $imgpheno::       Specifies the path to the ImgPheno package.
# $nbclassify::     Specifies the path to the NBClassify package.
#
# == Requires:
#
# - puppetlabs-apt
# - puppetlabs-apache
# - stankevich-python
#
# == Sample Usage:
#
#   class { 'orchid' :
#       domain => 'orchid.example.com',
#       doc_root => '/var/www/orchid',
#       site_root => '/opt/nbclassify/html',
#       site_name => 'webapp',
#       venv_path => '/opt/nbclassify/html/env',
#       imgpheno => '/opt/imgpheno',
#       nbclassify => '/opt/nbclassify/nbclassify',
#   }
#
class orchid (
        $domain = 'orchid.example.com',
        $doc_root = '/var/www/orchid',
        $site_root,
        $site_name,
        $venv_path,
        $imgpheno,
        $nbclassify,
    ) {

    # Construct paths.
    $media_path = "${site_root}/media/"
    $static_admin_path = "${site_root}/${site_name}/static/admin/"
    $static_rest_path = "${site_root}/${site_name}/static/rest_framework/"
    $static_path = "${site_root}/orchid/static/"

    class { 'apt':
        apt_update_frequency => always,
    }

    # Enable unattended upgrades.
    class { 'apt::unattended_upgrades': }

    class {
        # Install Python and friends.
        'python':
            require    => Exec['apt_update'],
            version    => 'system',
            pip        => true,
            dev        => true,
            virtualenv => true,
            gunicorn   => false;

        # Install Apache.
        'apache':
            require             => Exec['apt_update'],
            package_ensure      => present,
            default_vhost       => false,
            default_mods        => true,
            default_confd_files => true,
            purge_configs       => true;
    }

    # Ubuntu 14.04 comes with outdated versions of these packages. They will be
    # downloaded and compiled while setting up the Python virtualenv.
    apt::builddep {
        'python-sklearn':;
        'python-sorl-thumbnail':;
    }

    # Install packages.
    package {
        'python-numpy':
            require => Exec['apt_update'],
            ensure => present;
        'python-opencv':
            require => Exec['apt_update'],
            ensure => present;
        'python-pyfann':
            require => Exec['apt_update'],
            ensure => present;
        'python-scipy':
            require => Exec['apt_update'],
            ensure => present;
        'python-sqlalchemy':
            require => Exec['apt_update'],
            ensure => present;
        'python-pil':
            require => Exec['apt_update'],
            ensure => present;
        'memcached':
            require => Exec['apt_update'],
            ensure => present;
        'python-memcache':
            require => Exec['apt_update'],
            ensure => present;
    }

    exec {
        # Create the SQLite database for OrchID.
        'orchid_migrate':
            require => Python::Virtualenv[$venv_path],
            command => "${venv_path}/bin/python manage.py migrate",
            cwd     => $site_root,
            creates => "${site_root}/db.sqlite3";
    }

    # Directories and symbolic links.
    file {
        $doc_root:
            ensure => directory,
            owner => 'www-data',
            group => 'www-data';

        $media_path:
            ensure => directory,
            owner => 'www-data',
            group => 'www-data';

        $site_root:
            ensure => directory,
            mode => 'g+rwx',
            group => 'www-data';

        "${site_root}/${site_name}/static/":
            ensure => directory;

        $static_admin_path:
            ensure => link,
            target => "${venv_path}/lib/python2.7/site-packages/django/contrib/admin/static/admin/";

        $static_rest_path:
            ensure => link,
            target => "${venv_path}/lib/python2.7/site-packages/rest_framework/static/rest_framework/";

        "${site_root}/db.sqlite3":
            require => Exec['orchid_migrate'],
            ensure => file,
            mode => 'g+rw',
            group => 'www-data';
    }

    # Setup the Python virtualenv for OrchID.
    python::virtualenv { $venv_path :
        require => [
            Apt::Builddep['python-sklearn'],
            Apt::Builddep['python-sorl-thumbnail'],
            Package['python-numpy'],
            Package['python-opencv'],
            Package['python-pyfann'],
            Package['python-scipy'],
            Package['python-sqlalchemy'],
            Package['python-pil'],
            Package['memcached'],
            Package['python-memcache'],
        ],
        ensure       => present,
        version      => 'system',
        requirements => "${site_root}/orchid/requirements.txt",
        systempkgs   => true,
        distribute   => true,
    }

    python::pip {
        'imgpheno':
            require     => Python::Virtualenv[$venv_path],
            pkgname     => 'imgpheno',
            ensure      => present,
            url         => $imgpheno,
            virtualenv  => $venv_path;
        'nbclassify':
            require     => Python::Virtualenv[$venv_path],
            pkgname     => 'nbclassify',
            ensure      => present,
            url         => $nbclassify,
            virtualenv  => $venv_path;
    }

    # Set up the virtual host.
    apache::vhost { $domain:
        require => [
            File[$doc_root],
            Exec['orchid_migrate'],
        ],
        docroot => $doc_root,
        port => '80',
        aliases => [
            { alias => '/media/', path => $media_path },
            { alias => '/static/admin/', path => $static_admin_path },
            { alias => '/static/rest_framework/', path => $static_rest_path },
            { alias => '/static/', path => $static_path },
            { alias => '/docs/', path => "${doc_root}/docs/" },
        ],
        directories => [
            {
                'path'     => $doc_root,
                'provider' => 'directory',
            },
            {
                'path'     => $media_path,
                'provider' => 'directory',
            },
            {
                'path'     => $static_admin_path,
                'provider' => 'directory',
            },
            {
                'path'     => $static_rest_path,
                'provider' => 'directory',
            },
            {
                'path'     => $static_path,
                'provider' => 'directory',
            },
            {
                'path'     => "${site_root}/${site_name}/wsgi.py",
                'provider' => 'files',
            },
        ],

        # Configure WSGI.
        wsgi_application_group      => '%{GLOBAL}',
        wsgi_daemon_process         => 'orchid',
        wsgi_daemon_process_options => {
            display-name => '%{GROUP}',
            deadlock-timeout => '10',
            python-path => "${site_root}:${$venv_path}/lib/python2.7/site-packages",
        },
        wsgi_import_script_options  => {
            process-group => 'orchid',
            application-group => '%{GLOBAL}'
        },
        wsgi_process_group          => 'orchid',
        wsgi_script_aliases         => {
            '/' => "${site_root}/${site_name}/wsgi.py"
        },
        wsgi_pass_authorization => 'On',
    }

}
