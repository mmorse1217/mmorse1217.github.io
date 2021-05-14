#!/usr/bin/env bash
set -e # halt script on error

bundle exec jekyll build
bundle exec htmlproofer --url-ignore /feed.xml,https://twitter.com/mmorse1217 ./_site --only-4xx --empty-alt-ignore
