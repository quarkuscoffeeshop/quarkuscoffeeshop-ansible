#!/bin/bash 
set -xe

cat > /etc/yum.repos.d/mongodb.repo<<EOF
[Mongodb]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF

dnf update -y

dnf install -y  python3-pip nc cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain mongodb-org vim

curl -OL https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel80-x86_64-100.1.1.rpm  \
  && rpm -ivh mongodb-database-tools-rhel80-x86_64-100.1.1.rpm \
  && rm mongodb-database-tools-rhel80-x86_64-100.1.1.rpm

curl -OL https://raw.githubusercontent.com/tosin2013/quarkus-cafe-demo-role/dev/files/sample_mongo_data.json \
  && mkdir -p /data/  \
  && mv sample_mongo_data.json /data/

curl -OL https://raw.githubusercontent.com/tosin2013/quarkus-cafe-demo-role/dev/files/load_database.sh \
  && chmod +x load_database.sh && mv load_database.sh /bin/load_database

curl -OL   https://raw.githubusercontent.com/tosin2013/quarkus-cafe-demo-role/dev/files/configure_mongodb_user.sh \
  && chmod +x configure_mongodb_user.sh && mv configure_mongodb_user.sh /bin/configure_mongodb_user