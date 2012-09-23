require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Category < ActiveRecord::Base; end
class Post < ActiveRecord::Base
  belongs_to :category
  denormalizes category: name
end

describe "DenormalizeField" do
  let(:category) { Category.new(name: "News") }
  let(:post)     { Post.new(category: category) }

  it "denormalizes fiels on save" do
    post.save!
    post.reload
    post.category_name.should == "News"
  end
end
