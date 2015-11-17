FROM alpine
MAINTAINER Jason Wilder mail@jasonwilder.com

# Install wget and install/updates certificates
RUN apk add --update nginx ca-certificates bash \
 && rm -rf /var/cache/apk/*

# Configure Nginx and apply fix for very long server names
COPY nginx.conf /etc/nginx/nginx.conf
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
# && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

# Install Forego - static musl build from https://github.com/ddollar/forego/issues/65#issuecomment-150591344
RUN wget -P /usr/local/bin https://github.com/hmalphettes/nginx-proxy/releases/download/0.0.0/forego \
 && chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.4.2

# Same binary build for docker-gen: https://github.com/hmalphettes/nginx-proxy/releases/tag/0.0.0
RUN wget -P /usr/local/bin https://github.com/hmalphettes/nginx-proxy/releases/download/0.0.0/docker-gen \
 && chmod u+x /usr/local/bin/docker-gen

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
