#!/usr/bin/env bash
docker build -t site:base --target=base .
docker build -t site:serve --target=server .
