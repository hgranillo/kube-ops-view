FROM alpine:3.7
MAINTAINER Henning Jacobs <henning@jacobs1.de>

EXPOSE 8080

RUN apk add --no-cache python3 python3-dev gcc musl-dev zlib-dev libffi-dev openssl-dev ca-certificates g++ make file && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pipenv gevent && \
    rm -rf /var/cache/apk/* /root/.cache /tmp/*

COPY scm-source.json /

COPY Pipfile /
COPY Pipfile.lock /

WORKDIR /
RUN pipenv install --system --deploy --ignore-pipfile

COPY kube_ops_view /kube_ops_view

ARG VERSION=dev
RUN sed -i "s/__version__ = .*/__version__ = '${VERSION}'/" /kube_ops_view/__init__.py
RUN apk del python3-dev musl-dev zlib-dev libffi-dev openssl-dev

ENTRYPOINT ["/usr/bin/python3", "-m", "kube_ops_view"]
