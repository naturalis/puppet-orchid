class { 'orchid' :
    domain => 'orchid.example.com',
    doc_root => '/var/www/orchid',
    site_root => '/opt/orchid/html',
    site_name => 'mysite',
    venv_path => '/opt/orchid/html/env',
}