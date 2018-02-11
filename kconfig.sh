#!/bin/bash

kernel_conf_path="./target/linux/x86/64/config-default"

 cat .kconfig | \
 while read CMD; do
   prefix=`echo ${CMD} | awk -F "=" '{print $1}'` ;
   option=`echo ${CMD} | awk -F "=" '{print $2}'`;
   grep -q "^$prefix=" ${kernel_conf_path} && sed "s@^$prefix=\(.*\)@$prefix=$option@g" -i ${kernel_conf_path} || sed "$ a$prefix=$option" -i ${kernel_conf_path};
 done
