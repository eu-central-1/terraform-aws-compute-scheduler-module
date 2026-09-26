# Amazon Linux 2023 based Python Lambda Image derived from here
# https://gallery.ecr.aws/lambda/python
#checkov:skip=CKV_DOCKER_2: No Heatlhcheck needed (The Dockerfile just extend general Lamdba image)
#checkov:skip=CKV_DOCKER_3: No User needed

FROM public.ecr.aws/lambda/python:3.14

COPY requirements.txt /var/lang/requirements.txt

# Install gcc if function has binary dependencies in a package
# RUN dnf install -y gcc && dnf clean all && rm -rf /var/cache/yum

RUN pip3 install --no-cache-dir -r /var/lang/requirements.txt
# RUN python3 -m pip install --no-cache-dir -r requirements.txt

COPY src/ /var/task/

ENV LOGGING=DEBUG

# Pass the name of the function handler as an argument to the runtime
CMD [ "handler.scheduler_handler" ]

# Testing
# ENTRYPOINT [ "/bin/bash", "-c" ]