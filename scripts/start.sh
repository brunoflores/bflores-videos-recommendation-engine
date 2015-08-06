#!/usr/bin/env bash

bundle -v | grep 'Bundler' &> /dev/null
if [ ! $? == 0 ]; then
  gem install bundler
fi
bundle install
ruby ./web-app/app.rb
