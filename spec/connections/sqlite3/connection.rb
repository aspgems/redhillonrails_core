print "Using SQLite3\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.configurations = {
  'sqlite3' => {
    :adapter => 'sqlite3',
    :database => ':memory:',
    :timeout => 500
  }

}

ActiveRecord::Base.establish_connection 'sqlite3'
