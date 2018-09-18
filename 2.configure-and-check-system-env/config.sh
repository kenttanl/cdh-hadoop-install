#!/bin/bash
#set -o xtrace
set -o nounset
SCRIPT=`readlink -f $0`
basedir=`dirname $SCRIPT`

chmod 755 -R $basedir/conf/*.py
chmod 755 $basedir/*.sh
chmod 755 -R $basedir/bin/