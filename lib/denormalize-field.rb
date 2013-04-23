require 'active_record'
require 'active_support'
require 'active_support/inflector'

class DenormalizeUpdater
  def self.sync_all
    DenormalizeFields::UPDATE_STATEMENTS.each do |sql|
      p "EXECUTING:"
      p sql
      p "-" * 88
      DenormalizeFields::CLASSES.first.connection.execute sql
    end
  end
end

module DenormalizeFields
  UPDATE_STATEMENTS = []
  CLASSES = []

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
      # postgres sql? "UPDATE #{table_name} SET #{_denormalized_field_name} = #{_klass.table_name}.#{_field_name} FROM #{table_name} c1 INNER JOIN #{_klass.table_name} c2 on c2.id = c1.#{key}_id"

      UPDATE_STATEMENTS.push 
      "UPDATE #{table_name} SET #{_denormalized_field_name} = #{_klass.table_name}.#{_field_name} FROM #{table_name} c1 INNER JOIN #{_klass.table_name} c2 on c2.id = c1.#{key}_id"
      CLASSES.push self
    end
  end
end

ActiveRecord::Base.send :extend, DenormalizeFields
