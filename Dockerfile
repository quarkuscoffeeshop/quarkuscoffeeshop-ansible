FROM --platform=linux/amd64 fedora:36

RUN dnf makecache && dnf install -y bind-utils openssl openssh-clients wget  python3-pip git bash-completion python3-jmespath ansible --setopt=install_weak_deps=False  && \
    dnf clean all &&  rm -rf /var/cache/yum 

RUN curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/pre-steps/configure-openshift-packages.sh && \
    chmod +x configure-openshift-packages.sh  && \
    bash -x ./configure-openshift-packages.sh   --install
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN mkdir /opt/workspace  && git config --global user.email "demo@quarkus.io" && git config --global user.name "Quarkus"
COPY . /opt/workspace
COPY files/env.variables /root/

CMD [ "/opt/workspace/files/quickstart.sh"]