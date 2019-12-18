FROM ubuntu:18.04

COPY bin /opt/app
EXPOSE 42421
EXPOSE 42420
WORKDIR /opt/app/

ENV PATH=/opt/app:$PATH

CMD ./entrypoint.sh
