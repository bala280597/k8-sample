# Cloud AKS Kubernetes Deployment in Azure Devops

| Deployment | Type| Author |
| -------- | -------- |--------|
| Azure Kubernetes Service |Cloud  | BALAMURUGAN BASKARAN|

# Mediawiki created page through automation

# Frontend:
# Database connection with frontend
![config](https://user-images.githubusercontent.com/47313756/93972046-2c15d380-fd8f-11ea-94fb-44615f6c769f.png)

# Localsetting.php
![LocalSetting](https://user-images.githubusercontent.com/47313756/93972055-3041f100-fd8f-11ea-9f72-c1d517620712.png)


# Final page:
![Mediawiki](https://user-images.githubusercontent.com/47313756/93746951-9275e700-fc13-11ea-9cf0-36f07446624f.png)

# Backend:
![SQL sync](https://user-images.githubusercontent.com/47313756/93747085-cd781a80-fc13-11ea-9e5f-d33ca4c1533e.png)

# Continious Monitoring with shell script in Azure Devops
![monitor](https://user-images.githubusercontent.com/47313756/94228572-e128c700-ff1a-11ea-954c-09124768151d.png)

By this operation, The pipeline is cron job for every 30  minutes to check whether the server is up and running.

# Description:
In this project, I am deploying binaries of sample java application in Azure Kubernetes Service in desired cluster using docker image.
For Continious Integeration of Docker Build and AKS Deployment, I used Azure Devops. I developed automation script in `azure-pipelines.yml` .

# Purpose:
The purpose of the project is to  build the docker file and deploy it in AKS. I created pipeline for the operation. If any commit on respective branch , Pipeline would be triggered. We can also manually trigger the pipeline.

# Agent:
I used Azure agent for the pipeline operation for the time being. The best practice is to use Self Hosted Agents that keep us away from tools installation and reduces running time.

```YAML
pool:
    vmImage: 'ubuntu-latest'
```
# Pipeline creation:
In the Pipeline , we have 2 boolean parameters called 'BUILD' and 'DEPLOY'. By this parameters we can select the BUILD and  DEPLOY stages. In some case , If we want to delete or list the pods or other kinds in K8s , we don't need to build a docker image. In that scenario we can select DEPLOY checkbox itself. Only Deploy stage will run.
Some other parameters also mandatory , I would explain in later part of this article while explain about DEPLOY stage.

![Pipeline](https://user-images.githubusercontent.com/47313756/93747675-ab32cc80-fc14-11ea-826b-56d273c38d9a.png)


```yaml DOCKERFILE
trigger:
- master

parameters:
- name: BUILD
  type: boolean
  default: true
- name: DEPLOY
  type: boolean
  default: true
- name: serviceConnection
  default: '' 
- name: nameSpace
  default: '' 
- name: commands
  default: '' 
- name: arguments
  default: '' 
resources:
- repo: self
variables:
  tag: '$(Build.BuildId)'
stages:
- stage: Build
  displayName: Build image
  jobs:  
  - ${{ if eq(parameters.BUILD, true) }}:
    - job: Build
      displayName: Build
      pool:
        vmImage: 'ubuntu-latest'
      steps:
      - task: Docker@2
        inputs:
          containerRegistry: 'Docker'
          repository: 'bala2805/k8s_project'
          command: 'buildAndPush'
          Dockerfile: '**/Dockerfile'
          tags: |
            $(tag)  
  - ${{ if eq(parameters.DEPLOY, true) }}:          
    - job: DEPLOY
      displayName: DEPLOY
      pool:
        vmImage: 'ubuntu-latest'
      steps: 
      steps:
      - bash: |
         export REPLICAS=${{variables.REPLICAS}}
         export TARGETPORT=${{variables.TARGETPORT}}
         export IMAGE=${{variables.IMAGE}}
         export CONTAINERPORT=${{variables.CONTAINERPORT}}
         cat ${{ parameters.arguments }} | envsubst > deployment.yml
      - task: Kubernetes@1
        displayName: kubectl apply using arguments
        inputs:
          connectionType: Kubernetes Service Connection
          kubernetesServiceEndpoint: ${{ parameters.serviceConnection }}
          namespace: ${{ parameters.nameSpace }}
          command: ${{ parameters.commands }}
          arguments: -f deployment.yml
```

# BUILD stage:
I created `Dockerfile`. As entire flow needs containerization. In this stage , docker image is built, tagged and pushed to registry.
```yaml DOCKERFILE
FROM ubuntu:16.04

RUN apt-get update && \
      apt-get -y install sudo

RUN \
    groupadd -g 999 bala && useradd -u 999 -g bala -G sudo -m -s /bin/bash bala && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "bala ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the bala user!" && \
    echo "bala user:";  su - bala -c id

# switch user bala
USER bala
RUN  sudo apt-get -y update 

#switch user root
USER root
RUN  apt-get -y update && apt-get -y upgrade

#Install php apache packages
RUN   apt-get -y install apache2 \
                                php php-mysql\
                                libapache2-mod-php\
                                php-xml\
                                php-mbstring
RUN apt-get install -y php-apcu \
                              php-intl\
                              imagemagick\
                              inkscape\
                               php-gd\
                              php-cli\
                              php-curl\
                              git\
                              wget                  



#Port expose and php deploy
WORKDIR /tmp/
EXPOSE 80

#mediawiki deployment in apache2
RUN  wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.2.tar.gz
RUN tar -xvzf /tmp/mediawiki-1.33.2.tar.gz
RUN mkdir /var/lib/mediawiki
RUN mv mediawiki-*/* /var/lib/mediawiki
RUN ln -s /var/lib/mediawiki /var/www/html/mediawiki

#Configure and install sql
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
 && mkdir /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld
#volume
VOLUME ["/var/lib/mysql"]
EXPOSE 3306

CMD ["mysqld_safe"]
RUN systemctl enable mysql

#restart the apache server foreground
CMD ["apachectl", "-D", "FOREGROUND"]

```

In this dockerfile , I had consumed ubuntu:16.04 and configuring apache web server,php and sql in it . Volume mounted for Sql operation. Exposed 80 and 3306 ports in Dockerfile for SQL and webservice.
SO Backend and Frontend is managed.

In azure-pipelines.yml, I build the Docker image and push it to docker Hub.
Docker Hub url: `https://hub.docker.com/repository/docker/bala2805/k8s_project`

# DEPLOY Stage:
In the DEPLOY stage, In Azure pipeline , We need mandatory parameters to pass while triggering the pipeline to run this stage.
```YAML
kubernetesServiceEndpoint: Name of Kubernetes service connection that we created with our namespace.
namespace: Name of namespace where we deploy.
command: commands like create, apply, list etc
arguments: Path of deployment file
```
Note : As this approach , We can create every Kind in kubernetes in same yaml file or else need to create seperate task for each kind.
Example: We need to create Deployment and Service Kind means , I would recommend to create single YAML with Service and Deployment kind rather than seperate file for each.

![BothStages](https://user-images.githubusercontent.com/47313756/93747657-a40bbe80-fc14-11ea-998a-f53af37eb376.png)


# ENVIRONMENT Substitution with shell script
```YAML
export WEBREPLICA=${{variables.WEBREPLICA}}
          export WEB_SERVICEPORT=${{variables.WEB_SERVICEPORT}}
          export WEBCONTAINER_PORT=${{variables.WEBCONTAINER_PORT}}
          export IMAGE=${{variables.IMAGE}}
          export WEB_SERVICE_TYPE=${{variables.WEB_SERVICE_TYPE}}
          export SQL_CONTAINER_PORT=${{variables.SQL_CONTAINER_PORT}}
          export SQL_SERVICE_PORT=${{variables.SQL_SERVICE_PORT}}
          export STORAGE_MOUNT=${{variables.STORAGE_MOUNT}}
          
          cat ${{ parameters.arguments }} | envsubst > deployment.yml
```
The K8s deloy file is with Dynamic variable get substituted.

```yaml deploy.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver
spec:
 replicas: ${WEBREPLICA}
 selector:
   matchLabels:
    app: apache
 template:
   metadata:
    labels:
     app: apache
   spec:
    containers:
      - name: apache
        image: ${IMAGE}
        volumeMounts:
          - name: storage
            mountPath: /var/   
        ports:
        - name: apache
          containerPort: ${WEBCONTAINER_PORT}
        - name: mysql
          containerPort: ${SQL_CONTAINER_PORT}
    volumes:
    - name: storage
      emptyDir: {}   
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
  labels:
    run: web-service
spec:
  type: ${WEB_SERVICE_TYPE}
  ports:
  - name: apache
    port: ${WEB_SERVICEPORT}
    protocol: ${WEB_PROTOCOL}
  - name: sql
    port: ${SQL_SERVICE_PORT}
    protocol: ${SQL_PROTOCOL}
  selector:
    app: apache        

```
In the above Yaml, I had created Kind: Deployment and Service of front end and backend in single `deploy.yml` file.

![Deployment Stage](https://user-images.githubusercontent.com/47313756/93747670-a79f4580-fc14-11ea-87ae-54c62acdc320.png)

# Parameters for values.yml
The user can add following details in `values.yml` file which can be substituted for the deploy.yml.
```YAML
variables:
  #webservice_frontend
  WEBREPLICA: 1
  WEB_SERVICEPORT: 80
  WEBCONTAINER_PORT: 80
  IMAGE: bala2805/k8s_project:56
  WEB_SERVICE_TYPE: ClusterIP
  WEB_PROTOCOL: TCP
  #sqlservice_backend
  SQL_CONTAINER_PORT: 3306
  SQL_SERVICE_PORT: 3306
  SQL_PROTOCOL: TCP
  #dockerimage tagging with build id
  tag: '$(Build.BuildId)'
```
These variables are substituted in `deploy.yml`. So With these we can use our deployment file as template and passing variables dynamically.

# Thank You
