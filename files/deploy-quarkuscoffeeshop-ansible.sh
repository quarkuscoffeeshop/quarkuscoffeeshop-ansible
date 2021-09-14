#!/bin/bash
#set -e 
# For development export the enviorment variable below
export DEVELOPMENT=true 


if [ "$EUID" -ne 0 ]
then 
  export USE_SUDO="sudo"
fi

# Print usage
function usage() {
  echo -n "${0} [OPTION]
 Options:
  -d      Add domain 
  -o      OpenShift Token
  -p      Postgres Password
  -s      Store ID
  -h      Display this help and exit
  -r      Destroy coffeeshop 
  To deploy qaurkuscoffeeshop-ansible playbooks
  ${0}  -d ocp4.example.com -o sha-123456789 -p 123456789 -s ATLANTA
  To Delete qaurkuscoffeeshop-ansible playbooks from OpenShift
  ${0}  -d ocp4.example.com -o sha-123456789 -p 123456789 -s ATLANTA -r true
"
}

# community.kubernetes.helm_repository
function configure-ansible-and-playbooks(){
  echo "Check if community.kubernetes exists"
  if [ ! -d ~/.ansible/collections/ansible_collections/community/kubernetes ];
  then 
    echo "Installing community.kubernetes ansible role"
    ${USE_SUDO} git clone https://github.com/ansible-collections/kubernetes.core.git
    ${USE_SUDO} mkdir -p /home/${USER}/.ansible/plugins/modules
    ${USE_SUDO} cp kubernetes.core/plugins/action/k8s.py /home/${USER}/.ansible/plugins/modules/
    ${USE_SUDO} ansible-galaxy collection install community.kubernetes
    ${USE_SUDO} ansible-galaxy collection install kubernetes.core
    ${USE_SUDO} pip3 install kubernetes || exit $?
    ${USE_SUDO} pip3 install openshift || exit $?
    ${USE_SUDO} pip3 install jmespath || exit $?
  fi 

  echo "Check if Helm is installed exists"
  if [ ! -f "/usr/local/bin/helm" ];
  then 
    echo "Installing helm"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ${USE_SUDO} ./get_helm.sh
  fi 

  echo "Check if quarkuscoffeeshop-ansible role exists"
  if [ ! -z ${USE_SUDO} ];
  then 
    ROLE_LOC=$(${USE_SUDO}  find  /root/.ansible/roles -name quarkuscoffeeshop-ansible)
  else 
    ROLE_LOC=$(find  ~/.ansible/roles -name quarkuscoffeeshop-ansible)
  fi 
  

  if [[ $DEVELOPMENT == "false" ]] || [[ -z $DEVELOPMENT ]];
  then
    ${USE_SUDO} rm -rf ${ROLE_LOC}
    ${USE_SUDO} ansible-galaxy install   git+https://github.com/quarkuscoffeeshop/quarkuscoffeeshop-ansible.git
    echo "****************"
    echo "Start Deployment"
    echo "****************"
  elif  [ $DEVELOPMENT == "true" ];
  then 
    ${USE_SUDO} rm -rf ${ROLE_LOC}
    ${USE_SUDO} ansible-galaxy install   git+https://github.com/quarkuscoffeeshop/quarkuscoffeeshop-ansible.git,dev
    echo "****************"
    echo " Start Deployment "
    echo " DEVELOPMENT MODE "
    echo "****************"
  fi 
  
  checkpipmodules
  exit 1 
  
  ${USE_SUDO} ansible-playbook  /tmp/deploy-quarkus-cafe.yml
   #ansible-playbook  /tmp/deploy-quarkus-cafe.yml -t quay,gogs,pipelines,gitops,acm-workload --extra-vars delete_deployment=false -vv
   #ansible-playbook  /tmp/deploy-quarkus-cafe.yml -t quay,gogs,pipelines,gitops,acm-workload,amq,postgres --extra-vars delete_deployment=false -vv
   #ansible-playbook  /tmp/deploy-quarkus-cafe.yml -t amq,postgres --extra-vars delete_deployment=false -vv
   #ansible-playbook  /tmp/deploy-quarkus-cafe.yml -t amq,postgres,helm --extra-vars delete_deployment=false -vv
}

function destory_coffee_shop(){
  echo "******************"
  echo "Destroy Deployment"
  echo "******************"
  checkpipmodules
  ${USE_SUDO} ansible-playbook  /tmp/deploy-quarkus-cafe.yml
}

function checkpipmodules(){
  if python3 -c "import openshift" &> /dev/null; then
    echo 'openshift pip module is installed '
  else
      echo 'openshift pip module is not installed '
  fi

  if python3 -c "import kubernetes" &> /dev/null; then
    echo 'kubernetes pip module is installed '
  else
      echo 'kubernetes pip module is not installed '
  fi

  if python3 -c "import jmespath" &> /dev/null; then
    echo 'jmespath pip module is installed '
  else
      echo 'jmespath pip module is not installed '
  fi

}
if [ -z "$1" ];
then
  usage
  exit 1
fi

while getopts ":d:o:p:s:h:r:" arg; do
  case $arg in
    h) export  HELP=True;;
    d) export  DOMAIN=$OPTARG;;
    o) export  OCP_TOKEN=$OPTARG;;
    p) export POSTGRES_PASSWORD=$OPTARG;;
    s) export  STORE_ID=$OPTARG;;
    r) export  DESTROY=$OPTARG;;
  esac
done

if [[ "$1" == "-h" ]];
then
  usage
  exit 0
fi

export GROUP=$(id -gn)
export USERNAME=$(whoami)

echo -e "\n$DOMAIN  $OCP_TOKEN   $POSTGRES_PASSWORD $STORE_ID\n"

if [ -z "${DESTROY}" ];
then 
  export DESTROY=false
fi

if [ -f $HOME/env.variables ];
then 
  source  $HOME/env.variables
else
  read -p "Would you like to skip the ACM deployment? Default -> [true]: " SKIP_ACM_MANAGED
  SKIP_ACM_MANAGED=${SKIP_ACM_MANAGED:-"true"}
  read -p "Would you like to skip the AMQ Streams installation? Default ->[false] " SKIP_AMQ_STREAMS
  SKIP_AMQ_STREAMS=${SKIP_AMQ_STREAMS:-"false"}
  read -p "Would you like to skip the Postgres installation? Default ->[false] " SKIP_CONFIGURE_POSTGRES
  SKIP_CONFIGURE_POSTGRES=${SKIP_CONFIGURE_POSTGRES:-"false"}
  read -p "Would you like to skip the MongoDB Operator installation? Default ->[true] " SKIP_MONGODB_OPERATOR
  SKIP_MONGODB_OPERATOR=${SKIP_MONGODB_OPERATOR:-"true"}
  read -p "Would you like to skip the MongoDb OpenShift Template installation? Default ->[true] " SKIP_MONGODB
  SKIP_MONGODB=${SKIP_MONGODB:-"true"}
  read -p "Would you like to skip the Helm Deployment? Default ->[false] " SKIP_HELM_DEPLOYMENT
  SKIP_HELM_DEPLOYMENT=${SKIP_HELM_DEPLOYMENT:-"false"}
fi

cat >/tmp/deploy-quarkus-cafe.yml<<YAML
- hosts: localhost
  become: yes
  vars:
    openshift_token: ${OCP_TOKEN}
    openshift_url: https://api.${DOMAIN}:6443
    insecure_skip_tls_verify: true
    default_owner: ${USERNAME}
    default_group: ${GROUP}
    project_namespace: quarkuscoffeeshop-demo
    delete_deployment: "${DESTROY}"
    skip_acm_deployment: ${SKIP_ACM_MANAGED}
    skip_amq_install: ${SKIP_AMQ_STREAMS}
    skip_configure_postgres: ${SKIP_CONFIGURE_POSTGRES}
    skip_mongodb_operator_install: ${SKIP_MONGODB_OPERATOR}
    single_mongodb_install: ${SKIP_MONGODB} 
    skip_quarkuscoffeeshop_helm_install: ${SKIP_HELM_DEPLOYMENT}
    domain: ${DOMAIN}
    postgres_password: '${POSTGRES_PASSWORD}'
    storeid: ${STORE_ID}
  roles:
    - quarkuscoffeeshop-ansible
YAML

cat /tmp/deploy-quarkus-cafe.yml
sleep 3s 

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac


if [ "${machine}" == 'Linux' ] && [ -f /bin/ansible ];
then 
  if [ "${DESTROY}" == false ];
  then 
    configure-ansible-and-playbooks
  else 
    destory_coffee_shop
  fi
elif [ "${machine}" == 'Mac' ] && [ -f /usr/local/bin/ansible ];
then
  if [ "${DESTROY}" == false ];
  then 
    configure-ansible-and-playbooks
  else 
    destory_coffee_shop
  fi
else 
  echo "Ansible is not installed"
  exit 1
fi 
