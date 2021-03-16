#!/bin/bash
#set -e 

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

function deploy-amq-configure-postgres(){
  echo "Check if community.kubernetes exists"
  if [ ! -d ~/.ansible/collections/ansible_collections/community/kubernetes ];
  then 
    echo "Installing community.kubernetes ansible role"
    ${USE_SUDO} ansible-galaxy collection install community.kubernetes
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
  
  if [ ! -d ${ROLE_LOC} ];
  then 
    echo "Installing ansible role"
    ${USE_SUDO} ansible-galaxy install  git+https://github.com/quarkuscoffeeshop/quarkuscoffeeshop-ansible.git
  else
    ${USE_SUDO} -rm ${ROLE_LOC}
    ${USE_SUDO} ansible-galaxy install   git+https://github.com/quarkuscoffeeshop/quarkuscoffeeshop-ansible.git
    echo "ansible-playbook  deploy-quarkus-cafe.yml"
  fi 

  echo "****************"
  echo "Start Deployment"
  echo "****************"
  ${USE_SUDO} ansible-playbook  /tmp/deploy-quarkus-cafe.yml
}

function destory_coffee_shop(){
  echo "******************"
  echo "Destroy Deployment"
  echo "******************"
  ${USE_SUDO} ansible-playbook  /tmp/deploy-quarkus-cafe.yml
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
    skip_amq_install: false
    skip_configure_postgres: false
    skip_mongodb_operator_install: true
    skip_quarkuscoffeeshop_helm_install: true
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
    deploy-amq-configure-postgres
  else 
    destory_coffee_shop
  fi
elif [ "${machine}" == 'Mac' ] && [ -f /usr/local/bin/ansible ];
then
  if [ "${DESTROY}" == false ];
  then 
    deploy-amq-configure-postgres
  else 
    destory_coffee_shop
  fi
else 
  echo "Ansible is not installed"
  exit 1
fi 
