require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Category < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :category
  denormalizes category: :name
end

describe "DenormalizeField" do
  let(:category) { Category.new(name: "News") }
  let(:post)     { Post.new(category: category) }

  it "denormalizes fields on save" do
    post.save!
    post.reload
    post.category_name.should == "News"
  end

  it "updates the denormalized field when the column changes" do
    post.save!
    category = Category.first
    category.name = "Sports"
    category.save!
    post.reload
    post.category_name.should == "Sports"
  end
end
