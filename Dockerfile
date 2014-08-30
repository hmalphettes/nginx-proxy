FROM ubuntu:14.04
MAINTAINER Jason Wilder jwilder@litl.com

# Install Nginx. google/debian:wheezy
RUN \
  echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" > /etc/apt/sources.list.d/nginx-stable-trusty.list && \
  echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main" >> /etc/apt/sources.list.d/nginx-stable-trusty.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C && \
  apt-get update && apt-get install -y curl nginx && \
  apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
#fix for long server names
  sed -i 's/.*server_names_hash_bucket_size .*/      server_names_hash_bucket_size 256;/g' /etc/nginx/nginx.conf && \
  sed -i 's/http[ ]+{/&\n      client_max_body_size 80M;/g' /etc/nginx/nginx.conf && \
  mkdir -p /app && \
  curl -o /usr/local/bin/forego -L https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego && \
  chmod u+x /usr/local/bin/forego && \
  curl -o /app/docker-gen-linux-amd64-0.3.2.tar.gz -L https://github.com/jwilder/docker-gen/releases/download/0.3.2/docker-gen-linux-amd64-0.3.2.tar.gz && \
  tar xvzf /app/docker-gen-linux-amd64-0.3.2.tar.gz -C /app && \
  rm /app/docker-gen-linux-amd64-0.3.2.tar.gz

WORKDIR /app
ADD . /app
EXPOSE 80
ENV DOCKER_HOST unix:///tmp/docker.sock

CMD ["forego", "start", "-r"]
