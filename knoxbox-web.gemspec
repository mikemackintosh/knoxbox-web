# Created by hand, like a real man
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knoxbox-web/version'

Gem::Specification.new do |s|
  s.name        = 'knoxbox-web'
  s.version     = KnoxBoxWeb::VERSION
  s.date        = '2015-04-20'
  s.summary     = 'KnoxBox HTTP Management Interface'
  s.description = 'OpenVPN management tool'
  s.authors     = ['Mike Mackintosh']
  s.email       = 'm@zyp.io'
  s.homepage    =
    'http://github.com/mikemackintosh/knoxbox-web'

  s.license       = 'MIT'

  s.require_paths = ['lib']
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency 'knoxbox'      
  s.add_dependency 'sinatra'
  s.add_dependency 'sinatra-contrib'
  s.add_dependency 'sinatra-cross_origin'
  s.add_dependency 'sinatra-activerecord'
  s.add_dependency 'statsd'
  s.add_dependency 'statsd-ruby'
  s.add_dependency 'activerecord'
  s.add_dependency 'mysql2'
  s.add_dependency 'httparty'
  s.add_dependency 'bcrypt'
  s.add_dependency 'shotgun'
  s.add_dependency 'unicorn'
  s.add_dependency 'thin'
  s.add_dependency 'ipaddress'
  s.add_dependency 'sqlite3'
  s.add_dependency 'net-ldap'
  s.add_dependency 'ruby-radius'
  s.add_dependency 'sinatra-flash'
  s.add_dependency 'rotp'
  s.add_dependency 'signet'
  s.add_dependency 'google-api-client'
  s.add_dependency 'slackdraft'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rubocop'
end
