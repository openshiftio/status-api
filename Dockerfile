FROM registry.centos.org/kbsingh/openshift-nginx:latest
MAINTAINER Vasek Pavlin <vasek@redhat.com>

EXPOSE 8080
WORKDIR /opt/status-api

USER root

ADD . /opt/status-api
RUN yum -y install python-pip python-devel gcc &&\
    pip install -r requirements.txt &&\
    cp -r root/* / &&\
    cp scripts/run.sh /usr/bin/ &&\
    yum -y remove python-devel; yum clean all

RUN chgrp -R 0 /opt/status-api &&\
    chmod -R g+rwX /opt/status-api &&\
    chmod +x /usr/bin/run.sh

# There is a bug in py-zabbix==1.1.0 that doesn't handle properly urllib2 with
# self-signed certs. This patch will force it to work with unverified SSLs.
RUN sed -i 's/2, 7, 9/2, 7, 5/g' /usr/lib/python2.7/site-packages/pyzabbix/api.py

USER 1001

ENTRYPOINT ["/usr/bin/run.sh"]
