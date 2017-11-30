# gitlab-ce on alpine linux

[![Docker Repository on Quay](https://quay.io/repository/toshi0123/gitlab-ce/status "Docker Repository on Quay")](https://quay.io/repository/toshi0123/gitlab-ce)

This image is under developing.  
Configure files are not stored in any volumes. So if you test this image, you have to backup by yourself.  

This gitlab-ce built from source files.  
You can check the installation guides as follows.  
https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md

This docker image contains
1. gitlab-ce(postgres)
1. gitlab-shell
1. gitaly
1. gitlab-workhorse
1. nginx

Postgresql and redis are not contained in this image.  
You have to setup by yourself.  
