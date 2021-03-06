FROM ubuntu:latest as base
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime  && \
     apt-get update && \
     apt-get install -y tzdata  curl && \
    dpkg-reconfigure --frontend noninteractive tzdata   &&\
    apt-get autoremove -y && \
    #apt-get purge -y ca-certificates &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN apt-get update && \
#    apt-get install -y \
#    build-essential \ 
#    gcc \
#    make \
#    zlib1g-dev \
#    vim\
#    curl \
#    libxml2 \
#    libxslt-dev \
#    patch \
#    liblzma-dev \
#    ruby-dev
    # && \
    #$apt-get autoremove -y && \
    #apt-get clean && \
    #rm -rf /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y \
    build-essential \ 
    git \
    ruby-full && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /src && gem install bundler
WORKDIR /src
ADD Gemfile Gemfile
ADD jekyll-theme-so-simple.gemspec jekyll-theme-so-simple.gemspec
RUN bundle install
ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
CMD ["/bin/bash"]

#RUN gem install bundler
#RUN mkdir /src
#WORKDIR /src
#ADD Gemfile Gemfile
#RUN bundle
#
#
#COPY entrypoint.sh entrypoint.sh
##RUN bundle update i18n
#ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
#CMD ["bash", "/src/entrypoint.sh"]
#RUN bundle install
#FROM base as server
#WORKDIR /src
#ENTRYPOINT ["/usr/local/bin/bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--incremental"]

