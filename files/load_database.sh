#!/bin/bash 

set -x 

mongoimport --db cafedb --collection inventory \
          --authenticationDatabase cafedb --username ${MONGO_USERNAME} --password ${MONGO_PASSWORD} \
          --drop --file /data/sample_mongo_data.json  --host ${MONGO_CONNECTION_STRING} --port 27017