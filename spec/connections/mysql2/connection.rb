print "Using MySQL2\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.configurations = {
  'mysql2' => {
    :adapter => 'mysql2',
    :database => 'redhillonrails_core',
    :username => (ENV["TRAVIS"] ? '' : 'redhillonrails'),
    :encoding => 'utf8',
  }

}

ActiveRecord::Base.establish_connection 'mysql2'
