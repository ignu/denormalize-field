require 'active_record'
require 'active_support'
require 'active_support/inflector'

module DenormalizeFields
  def denormalizes(hash)
    hash.keys.each do |key|
      _field_name = hash[key]
      _original_klass = self
      _denormalized_field_name = "#{key}_#{_field_name}"

      before_save do
        if self.send(key)
          self.send "#{_denormalized_field_name}=", self.send(key).send(_field_name)
        end
      end

      _klass = key.to_s.camelize.constantize
      _klass.after_save do
        if self.send "#{_field_name}_changed?"
          self.send(_original_klass.name.downcase.pluralize).each do |child|
            child.update_attribute _denormalized_field_name, self.send(_field_name)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :extend, DenormalizeFields
