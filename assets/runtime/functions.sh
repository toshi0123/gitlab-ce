#!/bin/sh

prepare_config(){
  [ -e $1 ] || return 1
  local basename=`basename $1`
  cp -pf $1.example /etc/gitlab/example
  cp -pf $1 /etc/gitlab/
}

link_config(){
  local basename=`basename $1`
  rm -f $1
  ln -s /etc/gitlab/$basename $1
}

diff_config(){
  local basename=`basename $1`
  local conf_filename="/etc/gitlab/$basename"
  if [ -e /etc/gitlab/example/$basename.example ];then
    diff -U0 /etc/gitlab/example/$basename.example $1.example | patch -N $conf_filename || { cat $conf_filename.rej;exit 1; }
  fi
  cp -pf $1.example /etc/gitlab/example
}
