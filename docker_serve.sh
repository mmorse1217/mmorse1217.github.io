#!/usr/bin/env bash
docker run --rm -p 4000:4000 -v `pwd`:/src site:serve "$@"
