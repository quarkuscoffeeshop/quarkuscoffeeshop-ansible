#!/bin/bash 

RANDOM_STRING=$(echo $RANDOM | md5sum | head -c 5; echo;)
if [ $DELETE_DEPLOYMENT == "true" ]; then
  echo "Deleting deployment..."
  /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING} -u true
else 
    /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING}
fi
