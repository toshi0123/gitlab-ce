FROM alpine:edge

RUN apk add --no-cache vim sudo git ruby ruby-rdoc ruby-irb ruby-bundler ruby-dev ruby-rake go nodejs yarn postgresql-client

ENV LANG=en_US.utf8

RUN sudo adduser -s /bin/nologin -g 'GitLab' -D git; \
	chown -R git:git /home/git; \
	cd /home/git; \
	TAG=`git ls-remote -t https://gitlab.com/gitlab-org/gitlab-ce.git | grep -v -e '\^{}' -e 'rc[0-9]*' -e 'pre' | grep -o 'v10\..*$' | tail -1`; \
	sudo -u git -H git clone --depth 1 -b ${TAG} https://gitlab.com/gitlab-org/gitlab-ce.git gitlab -v

COPY assets /home/git/build/
RUN ash /home/git/build/install.sh

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 22/tcp 80/tcp 443/tcp

CMD ["tail -f /var/log/gitlab/*.log"]
