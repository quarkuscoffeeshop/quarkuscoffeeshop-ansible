Quarkus Cafe Role
=========

The Quarkus Cafe Role will deploy an event-driven demo application built with Quarkus, AMQ Streams (Kafka), and MongoDB. The application deploys to OpenShift (Kubernetes.)
The source code for the  [quarkus-cafe-demo](https://github.com/jeremyrdavis/quarkus-cafe-demo) application can be found  [here](https://github.com/jeremyrdavis/quarkus-cafe-demo).

Requirements
------------

* OpenShift 4.x Cluster installed
* Ansible should be installed on machine

ScreenShots
------------------------------------------------
![quarkus cafe topology](images/quarkus-cafe-applications.png "quarkus cafe topology")

![quarkus cafe kafka topics](images/ams-topics.png "quarkus cafe  kafka topics")


http://quarkus-cafe-web-quarkus-cafe-demo.apps.example.com/cafe example
![quarkus cafe application](images/webpage-example.png "quarkus appliation")


Usage
----------------
* Default web page
http://quarkus-cafe-web-quarkus-cafe-demo.apps.example.com/cafe
this endpoint is used to view the events coming into the cluster
* If you deploy skip_quarkus_cafe_customermock this will automatically push events to the quarkus cafe dashboard.
* If you would like to manally push events to AMQ use the command below.
```shell
export ENDPOINT="quarkus-cafe-web-quarkus-cafe-demo.apps.ocp4.example.com"
curl  --request POST http://${ENDPOINT}/order \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
-d '{
    "beverages": [
        {
            "item": "COFFEE_WITH_ROOM",
            "name": "Mickey"
        },
        {
            "item": "CAPPUCCINO",
            "name": "Minnie"
        }
    ],
    "kitchenOrders": [
        {
            "item": "CAKEPOP",
            "name": "Mickey"
        },
        {
            "item": "CROISSANT",
            "name": "Minnie"
        }
    ]
}'
```


Role Variables
--------------
Type  | Description  | Default Value
--|---|--
deployment_method | docker or s2i build | docker
skip_amq_install |  Skip Red Hat AMQ Install  |  false
skip_quarkus_cafe_barista |  Skip quarkus-cafe-barista install  |  false
skip_quarkus_cafe_core |  Skip quarkus-cafe-core install  |  false
skip_quarkus_cafe_kitchen |  Skip quarkus-cafe-kitchen install  |  false
skip_quarkus_cafe_web |  Skip quarkus-cafe-web install  |  false
skip_quarkus_cafe_customermock |  Skip quarkus-cafe-customermock install  |  false
openshift_token | OpenShift login token  | 123456789
openshift_url | OpenShift target url  | https://master.example.com
project_namespace | OpenShift Project name for the quarkus-cafe | quarkus-cafe-demo
insecure_skip_tls_verify  |  Skip insecure tls verify  |  true
delete_deployment  | delete the deployment and project for quarkus-cafe-demo  | false
amqstartingCSV  | Red Hat AMQ csv version  |  amqstreams.v1.4.0
config_location  | default location for application templates  | "/tmp/"
git_url  | Default git url of quarkus-cafe-demo application  | https://github.com/jeremyrdavis/quarkus-cafe-demo.git
quarkus_build_memory_limit  |  quarkus S2I memory build limit | 6Gi
quarkus_build_cpu_limit  |  quarkus S2I cpu build limit | 1
quarkus_core_build_memory_limit  |  quarkus-cafde-core S2I memory build limite  | 8Gi
quarkus_image_stream_name  |  quarkus s2i image version  | ubi-quarkus-native-s2i:20.0.0-java11
domain  |  OpenShift domain endpoint  | ocp4.example.com
kafka_stream_url  |  Kafka stream url | http://quarkus-cafe-web-{{ project_namespace}}.apps.{{ domain }}/dashboard/stream


Dependencies
------------

* Ansible
* OpenShift cli

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:
```
- hosts: localhost
  become: yes
  vars:
    deployment_method: docker
    openshift_token: 123456789
    openshift_url: https://api.ocp4.example.com:6443
    insecure_skip_tls_verify: true
    project_namespace: quarkus-cafe-demo
    delete_deployment: false
    skip_amq_install: false
    skip_quarkus_cafe_barista: false
    skip_quarkus_cafe_core: false
    skip_quarkus_cafe_kitchen: false
    skip_quarkus_cafe_web: false
    skip_quarkus_cafe_customermock: false
    quarkus_build_memory_limit: 6Gi
    quarkus_build_cpu_limit: 1
    quarkus_core_build_memory_limit: 8Gi
    domain: ocp4.example.com
  roles:
    - quarkus-cafe-demo-role
```


Troubleshooting
---------------
Force delete kafka crds after bad install
```
oc get crds -o name | grep '.*\.strimzi\.io' | xargs -r -n 1 oc delete
```

To-Do
-------
* Deployment vs Deployment Config Option
* Need to test against Openshift 4.4

License
-------

GPLv3

Author Information
------------------

This role was created in 2020 by [Tosin Akinosho](https://github.com/tosin2013)
