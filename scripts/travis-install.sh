#!/bin/bash -eux

sudo wget "http://archive.cloudera.com/$CDH/ubuntu/precise/amd64/cdh/cloudera.list" \
    -O /etc/apt/sources.list.d/cloudera.list
sudo apt-get update

#
# Hive
#

sudo apt-get install -y --force-yes hive
sudo cp $(dirname $0)/travis-conf/hive/* /etc/hive/conf
sudo -u hive mkdir /tmp/hive && sudo chmod 777 /tmp/hive
sudo apt-get install -y --force-yes hive-metastore hive-server2

sudo -Eu hive $(dirname $0)/make_test_tables.sh

#
# Presto
#

sudo apt-get install -y python # Use python2 for presto server
sudo apt-get install -y oracle-java8-installer
sudo update-java-alternatives -s java-8-oracle

curl https://repo1.maven.org/maven2/com/facebook/presto/presto-server/$PRESTO/presto-server-$PRESTO.tar.gz \
    | tar zxf -

cp -r $(dirname $0)/travis-conf/presto presto-server-$PRESTO/etc
sed -i s/%CDH%/$CDH/g presto-server-$PRESTO/etc/catalog/hive.properties

/usr/bin/python2.7 presto-server-$PRESTO/bin/launcher.py start
