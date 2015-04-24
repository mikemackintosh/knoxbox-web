require 'bundler/setup'

Bundler.require(:default)

require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/contrib'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'sinatra/activerecord'

# 3rd Party Deps
require 'securerandom'
require 'slackdraft'

# stdlib Extensions
require 'knoxbox-web/ext/hash'

# Set Project Root
PROJECT_ROOT = File.dirname(__FILE__)

# Load KnoxBox Stuff
require 'knoxbox-web/version'
require 'knoxbox-web/config'

# Lets load up the config
CONFIG.load( ENV['KNOXBOX'] ||= File.join(
  PROJECT_ROOT,
  '..',
  'config',
  'config.yml',
))

#require 'knoxbox-web/stats'
require 'knoxbox-web/base'
require 'knoxbox-web/errors'

# Set Hosted Domain
HOSTED_DOMAIN = ENV['DOMAIN']