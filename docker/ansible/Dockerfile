ARG arch
ARG ver
FROM homemate/alpine-s6:${ver}-${arch}

RUN apk-install python libffi openssl openssh-keygen \
    && apk-install -t .build-deps py-pip git build-base \
    	python-dev libffi-dev openssl-dev \
    && pip install git+https://github.com/ansible/ansible.git@devel \
    && pip install boto boto3 docker \
    && curl -sSL "https://github.com/dariko/ansible-module-docker_stack/raw/master/docker_stack" \
	> /usr/lib/python2.7/site-packages/ansible/modules/cloud/docker/docker_stack.py \
    && apk-remove .build-deps \
    && find /usr/lib/python2.7 -type f | grep -E '\.exe$' | xargs rm \
    && cont-cleanup

WORKDIR /etc/ansible

ENTRYPOINT ["ansible-playbook"]
