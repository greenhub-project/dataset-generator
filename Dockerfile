FROM alpine:3.6

ARG USER=user
ARG UID=1000
ARG GID=1000

RUN apk add --no-cache --virtual mysql-client
RUN apk add --no-cache --virtual p7zip

RUN addgroup -g ${GID} -S ${USER} \
    && adduser -S -D -g "" \
    -u ${UID} \
    -G ${USER} \
    ${USER}

ADD ./entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/${USER}

USER ${USER}

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
