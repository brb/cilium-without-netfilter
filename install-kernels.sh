#!/bin/bash

set -ex

wget 'https://gitlab.com/brb/linux-5.3-wo-nf/raw/master/linux-headers-5.3.0-nonf_5.3.0-nonf-1_amd64.deb'
wget 'https://gitlab.com/brb/linux-5.3-wo-nf/raw/master/linux-image-5.3.0-nonf_5.3.0-nonf-1_amd64.deb'
wget 'https://gitlab.com/brb/linux-5.3-with-nf/raw/master/linux-headers-5.3.0-nf_5.3.0-nf-1_amd64.deb'
wget 'https://gitlab.com/brb/linux-5.3-with-nf/raw/master/linux-image-5.3.0-nf_5.3.0-nf-1_amd64.deb'

dpkg -i *.deb

update-grub
