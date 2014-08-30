FROM google/debian:wheezy
MAINTAINER Jason Wilder jwilder@litl.com

# Install Nginx.
RUN \
  echo "deb http://debian.gtisc.gatech.edu/debian wheezy-backports main" >> /etc/apt/sources.list.d/squeeze-backports.list && \
  apt-get update && apt-get -y -t wheezy-backports install nginx curl && \
  apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
#fix for long server names
  sed -i 's/.*server_names_hash_bucket_size .*/      server_names_hash_bucket_size 256;\n      client_max_body_size 80M;/g' /etc/nginx/nginx.conf && \
  mkdir /app && \
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