ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

RUN apk-install bash python libffi openssl \
    && apk-install -t .build-deps py-pip git build-base \
    	python-dev libffi-dev openssl-dev \
    && pip install git+https://github.com/ansible/ansible.git@devel \
    && pip install boto boto3 docker docker-compose \
    && curl -sSL "https://github.com/dariko/ansible-module-docker_stack/raw/master/docker_stack" \
	> /usr/lib/python2.7/site-packages/ansible/modules/cloud/docker/docker_stack.py \
    && apk-remove .build-deps \
    && find /usr/lib/python2.7 -type f | grep -E '\.pyc$|\.pyo$|\.exe$' | xargs rm \
    && rm -rf /usr/lib/python2.7/idlelib  /usr/lib/python2.7/lib-tk \
    && cont-cleanup

RUN apk-install openssh-keygen

WORKDIR /etc/ansible

ENTRYPOINT ["ansible-playbook"]
