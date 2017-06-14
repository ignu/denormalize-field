require 'erb'
require 'uri'
require 'em-synchrony/activerecord'

class DbConnect
  attr_accessor :config
  def initialize
    @db = URI.parse(ENV['DATABASE_URL'] || 'http://localhost')
    if @db.scheme == 'postgres' # Heroku
      ActiveRecord::Base.establish_connection(
        :adapter  => @db.scheme == 'postgres' ? 'postgresql' : @db.scheme,
        :host     => @db.host,
        :username => @db.user,
        :password => @db.password,
        :database => @db.path[1..-1],
        :encoding => 'utf8'
      )
    else
      environment = ENV['DATABASE_URL'] ? 'production' : 'development'
      @db = YAML.load(ERB.new(File.read('config/database.yml')).result)[environment]
      ActiveRecord::Base.establish_connection(@db)
      @config = ActiveRecord::Base.connection.pool.spec.config
    end
  end
end

# connect to the database
DbConnect.new
