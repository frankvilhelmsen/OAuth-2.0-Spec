$LOAD_PATH.unshift(File.expand_path('../../..', __FILE__))

require 'rspec/expectations'
require 'rack/test'

require 'run-app'

module AppHelper
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

World(Rack::Test::Methods, AppHelper)

