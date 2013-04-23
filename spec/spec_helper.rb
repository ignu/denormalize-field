$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'denormalize-field'
require 'db_connect'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:each) do
    Post.delete_all
    Category.delete_all
  end
end

ActiveRecord::Base.establish_connection adapter:'postgresql', database: 'denormalizefielddev'

begin
  ActiveRecord::Base.connection.drop_table(:categories)
  ActiveRecord::Base.connection.drop_table(:posts)
rescue
end

ActiveRecord::Base.connection.create_table(:categories) do |t|
  t.string :name
  t.timestamps
end

ActiveRecord::Base.connection.create_table(:posts) do |t|
  t.integer :category_id
  t.string :category_name
  t.timestamps
end
