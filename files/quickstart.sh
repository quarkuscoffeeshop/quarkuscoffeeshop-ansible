#!/bin/bash 
set -xe 
RANDOM_STRING=$(echo $RANDOM | md5sum | head -c 5; echo;)
echo "CLUSTER_DOMAIN_NAME: $CLUSTER_DOMAIN_NAME"

if [ -z  ${CLUSTER_DOMAIN_NAME} ]; then
    echo "CLUSTER_DOMAIN_NAME is not set"
    exit 1
fi

if [ -z  ${TOKEN} ]; then
  echo "Token is not set"
  exit 1
fi

echo "********************************************************************************"
echo "Current Settings are:"
echo "ACM_WORKLOADS=$(echo $ACM_WORKLOADS)" >> $HOME/env.variables
echo "AMQ_STREAMS=$(echo $AMQ_STREAMS)" >> $HOME/env.variables
echo "CONFIGURE_POSTGRES=$(echo $CONFIGURE_POSTGRES)" >> $HOME/env.variables
echo "HELM_DEPLOYMENT=$(echo $HELM_DEPLOYMENT)" >> $HOME/env.variables
echo "DELETE_DEPLOYMENT=$(echo $DELETE_DEPLOYMENT)" >> $HOME/env.variables
echo "MONGODB_OPERATOR=n" >> $HOME/env.variables
echo "MONGODB=n" >> $HOME/env.variables
cat $HOME/env.variables
echo "********************************************************************************"
sleep 5s
if [ $DELETE_DEPLOYMENT == "true" ]; then
   echo "Deleting deployment..."
   /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING} -u true
else 
    /opt/workspace/files/deploy-quarkuscoffeeshop-ansible.sh  -d ${CLUSTER_DOMAIN_NAME} -t  ${TOKEN}  -s STORE-${RANDOM_STRING}
fi
