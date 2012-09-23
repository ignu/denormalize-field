require 'active_record'

module DenormalizeFields
  def denormalizes(hash)
    hash.keys.each do |key|
      field = hash[key]
      before_save do
        self.send "#{key}_#{field}=", self.send(key).send(field)
        Category.after_save do
          self.posts.each do |post|
            post.update_attribute :category_name, self.name
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :extend, DenormalizeFields
