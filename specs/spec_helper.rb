ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Credence::Account.dataset.destroy
  Credence::Project.dataset.destroy
end

DATA = {}
DATA[:accounts] = YAML.load File.read('db/seeds/accounts_seed.yml')
DATA[:documents] = YAML.load File.read('db/seeds/documents_seed.yml')
DATA[:projects] = YAML.load File.read('db/seeds/projects_seed.yml')
