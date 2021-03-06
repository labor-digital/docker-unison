# Stolen from: https://github.com/EugenMayer/docker-image-unison

FROM alpine:edge

ARG OCAML_VERSION=4.03.0

RUN apk update \
    && apk add --no-cache --virtual .build-deps build-base coreutils \
	&& wget http://caml.inria.fr/pub/distrib/ocaml-${OCAML_VERSION:0:4}/ocaml-${OCAML_VERSION}.tar.gz \
	&& tar xvf ocaml-${OCAML_VERSION}.tar.gz -C /tmp \
	&& cd /tmp/ocaml-${OCAML_VERSION} \
    && ./configure \
    && make world \
    && make opt \
    && umask 022 \
    && make install \
    && make clean \
    && apk del .build-deps  \
	&& rm -rf /tmp/ocaml-${OCAML_VERSION} \
	&& rm /ocaml-${OCAML_VERSION}.tar.gz

ARG UNISON_VERSION=2.48.4
RUN apk add --no-cache build-base curl bash supervisor inotify-tools rsync ruby\
    && apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ ocaml \
    && curl -L https://github.com/bcpierce00/unison/archive/$UNISON_VERSION.tar.gz | tar zxv -C /tmp \
    && cd /tmp/unison-${UNISON_VERSION} \
    && sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c \
    && make UISTYLE=text NATIVE=true STATIC=true \
    && cp src/unison src/unison-fsmonitor /usr/local/bin \
    && apk del curl build-base ocaml \
    && apk add --no-cache libgcc libstdc++ \
    && rm -rf /tmp/unison-${UNISON_VERSION} \
    && apk add --no-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ shadow \
 	&& apk add --no-cache tzdata

############# ############# #############
############# SHARED        #############
############# ############# #############

# These can be overridden later
ENV TZ="Europe/Helsinki" \
    LANG="C.UTF-8" \
    UNISON_DIR="/data" \
    HOME="/root"

COPY entrypoint.sh /entrypoint.sh
COPY precopy_appsync.sh /usr/local/bin/precopy_appsync

RUN mkdir -p /docker-entrypoint.d \
 && chmod +x /entrypoint.sh \
 && mkdir -p /etc/supervisor.conf.d \
 && mkdir /unison \
 && touch /tmp/unison.log \
 && chmod u=rw,g=rw,o=rw /tmp/unison.log \
 && chmod +x /usr/local/bin/precopy_appsync

COPY supervisord.conf /etc/supervisord.conf
COPY supervisor.daemon.conf /etc/supervisor.conf.d/supervisor.daemon.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]
############# ############# #############
############# /SHARED     / #############
############# ############# #############


VOLUME /unison
EXPOSE 5000
