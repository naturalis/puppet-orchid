class { 'orchid' :
    domain => 'orchid.example.com',
    doc_root => '/var/www/orchid',
    site_root => '/opt/nbclassify/html',
    site_name => 'webapp',
    venv_path => '/opt/nbclassify/html/env',
    imgpheno => '/opt/imgpheno',
    nbclassify => '/opt/nbclassify/nbclassify',
}

class { 'orchid::docs' :
    sourcedir => '/opt/orchid/docs',
    outdir => '/var/www/orchid/docs',
}
