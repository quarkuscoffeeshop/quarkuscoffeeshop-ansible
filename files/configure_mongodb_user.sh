#!/bin/bash 
set -xe

cat >/tmp/populate-user-mongo-script.js<<EOF
db = db.getSiblingDB('cafedb')
db.createUser({
   user:"${MONGO_USERNAME}",
   pwd:"${MONGO_PASSWORD}",
   roles:[
            {
               role:"clusterAdmin",
               db:"admin"
            }            
         ]
      }
   )
EOF

mongo --host ${MONGO_CONNECTION_STRING} --port 27017 /tmp/populate-user-mongo-script.js
