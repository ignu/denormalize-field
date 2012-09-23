$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'denormalize-field'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:each) do
    Post.delete_all
    Category.delete_all
  end
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                       :database => File.dirname(__FILE__) + "/denormalize-field.sqlite3")

ActiveRecord::Base.connection.drop_table(:categories)
ActiveRecord::Base.connection.drop_table(:posts)
ActiveRecord::Base.connection.create_table(:categories) do |t|
  t.string :name
end
ActiveRecord::Base.connection.create_table(:posts) do |t|
  t.string :category_id
  t.string :category_name
end


