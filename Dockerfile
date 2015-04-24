FROM ubuntu
MAINTAINER Mike Mackintosh <m@zyp.io>

RUN apt-get update
RUN apt-get install -y build-essential \
      zlib1g-dev \
      libssl-dev \
      libreadline6-dev \
      libyaml-dev \
      nginx \
      supervisor \
      openvpn

# install ruby from source and cleanup afterward (from murielsalvan/ruby)
ADD http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.4.tar.gz /tmp/
RUN cd /tmp && \
      tar -xzf ruby-2.1.4.tar.gz && \
      cd ruby-2.1.4 && \
      ./configure && \
      make && \
      make install && \
      cd .. && \
      rm -rf ruby-2.1.4 && \
      rm -f ruby-2.1.4.tar.gz

ADD /contrib/nginx.conf /etc/nginx/nginx.conf
ADD /contrib/supervisor.conf /etc/supervisor.d/all.conf
ADD / /opt/knoxbox
WORKDIR /opt/knoxbox
#RUN gem install bundler --no-rdoc --no-ri
#RUN npm install -g grunt-cli
#RUN rm config/*.yml
#RUN mv -v config/config.yml.deploy config/config.yml
#RUN make deps
#RUN make test
#RUN make ui
#RUN touch /var/log/nginx.log
#RUN touch /var/log/knoxbox.log

EXPOSE 1194
EXPOSE 80
EXPOSE 443