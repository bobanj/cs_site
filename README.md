# README

## Requirements
* Ruby (see `.ruby-version` for version)
* Using [rbenv](https://github.com/rbenv/rbenv) is a good idea

## Installation

* Once ruby is installed:
```bash
gem install bundler
bundle install
bundle exec rake db:setup
```
* Start the server:
```bash
bundle exec rails s
```