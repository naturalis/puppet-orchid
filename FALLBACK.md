
    sudo su
    apt-add-repository -y ppa:gijzelaar/opencv2.4
    apt-get update
    apt-get install git build-essential ca-certificates 
    apt-get install python-setuptools python-dev python-pip python-numpy python-opencv python-pyfann python-sklearn python-yaml 
    update-ca-certificates 
    cd /opt
    git clone https://github.com/naturalis/nbclassify.git
    cd nbclassify/nbclassify
    pip install -r requirements.txt
    pip install https://github.com/naturalis/imgpheno/archive/master.zip
