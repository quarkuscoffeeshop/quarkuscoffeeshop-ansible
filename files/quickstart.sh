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

echo "********************************************************************************"
echo "Current Settings are:"
echo "ACM_WORKLOADS=${ACM_WORKLOADS}" >> $HOME/env.variables
echo "AMQ_STREAMS=${AMQ_STREAMS}" >> $HOME/env.variables
echo "CONFIGURE_POSTGRES=${CONFIGURE_POSTGRES}" >> $HOME/env.variables
echo "HELM_DEPLOYMENT=${HELM_DEPLOYMENT}" >> $HOME/env.variables
echo "DELETE_DEPLOYMENT=${DELETE_DEPLOYMENT}" >> $HOME/env.variables
echo "MONGODB_OPERATOR=n" >> $HOME/env.variables
echo "MONGODB=n" >> $HOME/env.variables
cat $HOME/env.variables
echo "********************************************************************************"
if [ $DELETE_DEPLOYMENT == "true" ]; then
   echo "Deleting deployment..."
   /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING} -u true
else 
    /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSERTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING}
fi
