#!/usr/bin/env bash
docker run --rm -p 4000:4000 -v `pwd`:/src site:latest bash entrypoint.sh 
#docker run --rm -p 4000:4000 -v `pwd`:/src site:latest bundle exec jekyll serve --host 0.0.0.0 --incremental
