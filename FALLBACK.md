
    sudo su
    apt-get update
    apt-get install git build-essential ca-certificates libopencv-dev 
    apt-get install python-setuptools python-dev python-pip python-numpy python-opencv python-pyfann python-sklearn python-yaml 
    update-ca-certificates 

REBOOT

    sudo su
    cd /opt
    git clone https://github.com/naturalis/nbclassify.git
    cd nbclassify/nbclassify
    pip install -r requirements.txt
    cd ../html/orchid
    pip install -r requirements.txt
    pip install https://github.com/naturalis/imgpheno/archive/master.zip
