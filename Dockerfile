FROM centos:7
# Install various packages to get compile environment
RUN yum groupinstall -y "Development Tools"

#Copy file to / directory
RUN mkdir -p /usr/temporary
COPY red.js /usr/temporary/

#install Python
RUN yum install -y gcc openssl-devel bzip2-devel libffi-devel
WORKDIR /usr/src
RUN yum -y --enablerepo=extras install epel-release && yum clean all && yum -y update
RUN yum -y update && yum -y install wget
RUN wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz && tar xzf Python-3.7.4.tgz

WORKDIR /usr/src/Python-3.7.4
RUN ./configure --enable-optimizations
RUN make altinstall

FROM node:12-alpine

# download latest stable node-gyp
RUN npm install -g --unsafe-perm node-gyp

# download latest stable node-red
RUN mkdir -p /root/.node-red
WORKDIR /root/.node-red
RUN npm install -g --unsafe-perm node-red

# download latest stable appmetrics-dash
RUN apk add g++ make python
#RUN npm install -g --unsafe-perm appmetrics-dash
RUN npm install -S appmetrics-dash

# overwrite red.js file with the version with the below 2 lines appended in the file
#var dash = require('appmetrics-dash');
#dash.attach();
WORKDIR /usr/temporary
COPY red.js /opt/app-root/src/packages/node_modules/node-red/

# expose port
EXPOSE 1880

# Set the default command to execute
# when creating a new container
CMD ["node-red","-v","--max-old-space-size=512","flow.json"]
# docker build --rm=true --tag=node-red .
# docker run -it -p 1880:1880 --name mynodered node-red
# docker run -it -p 1880:1880 -v ~/data:/root/.node-red --name mynodered node-red
