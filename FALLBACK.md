
    sudo su
    apt-get update
    
    # non-python pre-requisites
    apt-get install git build-essential ca-certificates libopencv-dev 
    
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

    # install imgpheno as 'editable'. The general idea is that there
    # could then be additional, truly editable installs elsewhere (i.e.
    # owned by 'ubuntu' in its $HOME) that we prepend to the $PYTHONPATH
    cd /opt
    git clone https://github.com/naturalis/imgpheno.git
    cd imgpheno
    pip install -e .
    cd ../

    # same thing for nbclassify
    git clone https://github.com/naturalis/nbclassify.git
    cd nbclassify/nbclassify
    pip install -e .

    # update PATH for unprivileged user
    exit    
    echo 'export PATH=$PATH:/opt/nbclassify/nbclassify/scripts/' >> ~/.profile
