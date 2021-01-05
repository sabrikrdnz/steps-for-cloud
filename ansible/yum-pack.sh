#!/bin/bash
ansible -m yum_repository -a "name=Centos-AppStream baseurl=http://ftp.itu.edu.tr/Mirror/CentOS/ description='ITU-CentosMirror' gpgcheck=1 gpgkey='' enabled=0"
