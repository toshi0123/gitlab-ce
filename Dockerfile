FROM alpine:edge

RUN apk upgrade --no-cache && \
    apk add --no-cache \
    vim sudo git ruby ruby-bundler ruby-rdoc nodejs postgresql-client \
    ruby-rake procps ruby-bigdecimal ruby-irb nginx

ENV LANG=en_US.utf8

COPY assets /home/git/build/

RUN adduser -s /bin/sh -g 'GitLab' -D git; \
    chown -R git:git /home/git; \
    ash /home/git/build/download_gitlab.sh && \
    ash /home/git/build/install.sh && \
    ash /home/git/build/default_setting.sh

COPY docker-entrypoint.sh configfile_list.txt /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80/tcp 443/tcp

VOLUME ["/home/git/data"]
