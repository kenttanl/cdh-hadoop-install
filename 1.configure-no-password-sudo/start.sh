#!/bin/sh
username=kt94	
password=negg.123

svrs=`cat host-ips | grep -v '^#'`

for svr in $svrs
do
  echo "*** go $svr start"
  echo "*** go $svr" >> log
  ./addsudo.exp  $svr  $username $password
  echo "*** go $svr end"
  echo "*** go $svr end" >> log
done

echo "*** end "
echo "*** end " >> log
