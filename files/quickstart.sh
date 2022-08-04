#!/bin/bash 
set -xe 
RANDOM_STRING=$(echo $RANDOM | md5sum | head -c 5; echo;)

if [ -z  ${CLUSERTER_DOMAIN_NAME} ]; then
    echo "CLUSERTER_DOMAIN_NAME is not set"
    exit 1
fi

if [ -z  ${TOKEN} ]; then
  echo "Token is not set"
  exit 1
fi


if [ $DELETE_DEPLOYMENT == "true" ]; then
   echo "Deleting deployment..."
   /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING} -u true
else 
    /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING}
fi
