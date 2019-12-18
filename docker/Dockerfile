FROM ubuntu:18.04

COPY bin /opt/app
EXPOSE 42025
EXPOSE 42024
WORKDIR /opt/app/

ENV PATH=/opt/app:$PATH

CMD ./entrypoint.sh
