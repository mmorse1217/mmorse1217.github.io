FROM ubuntu:latest as base
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime  && \
     apt-get update && \
     apt-get install -y tzdata  && \
    dpkg-reconfigure --frontend noninteractive tzdata   &&\
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    #apt-get purge -y ca-certificates &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    build-essential \ 
    gcc \
    make \
    zlib1g-dev \
    vim\
    curl \
    libxml2 \
    libxslt-dev \
    ruby-full && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler:1.15.3
RUN mkdir /src
WORKDIR /src
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
COPY entrypoint.sh entrypoint.sh
RUN /usr/local/bin/bundler install
ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
CMD ["bash", "/src/entrypoint.sh"]

FROM base as server
WORKDIR /src
ENTRYPOINT ["/usr/local/bin/bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--incremental"]

