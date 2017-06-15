require 'active_record'
require 'active_support'
require 'active_support/inflector'

class DenormalizeUpdater
  def self.sync_all
    DenormalizeFields::UPDATE_STATEMENTS.each do |sql|
      DenormalizeFields::CLASSES.first.connection.execute sql
    end
  end
end

module DenormalizeFields
  UPDATE_STATEMENTS = []
  CLASSES = []

  def denormalizes(hash)
    hash.keys.each do |key|
      field_name = hash[key]
      original_klass = self
      denormalized_field_name = "#{key}_#{field_name}"

      before_save do
        if self.send(key)
          self.send "#{denormalized_field_name}=", self.send(key).send(field_name)
        end
      end

      klass = key.to_s.camelize.constantize
      update_sql = "UPDATE #{table_name} SET #{denormalized_field_name} = c2.#{field_name} FROM #{table_name} c1 INNER JOIN #{klass.table_name} c2 on c2.id = c1.#{key}_id"

      klass.after_save do
        if self.send "saved_change_to_#{field_name}?"
          quoted_value = ActiveRecord::Base.connection.quote self.send(field_name)
          update_sql = "UPDATE #{original_klass.table_name} SET #{denormalized_field_name} = #{quoted_value} where #{key}_id = #{self.id}"
          self.class.connection.execute update_sql
        end
      end

      self.class.class_eval <<-EVAL
        define_method "#{klass.table_name}_out_of_sync" do
          #{self.name}.where("id in (SELECT c1.id FROM #{table_name} c1 INNER JOIN #{klass.table_name} c2 on c2.id = c1.#{key}_id where c1.#{denormalized_field_name} != c2.#{field_name})")
        end
        EVAL

      UPDATE_STATEMENTS.push update_sql
      CLASSES.push self
    end
  end
end

ActiveRecord::Base.send :extend, DenormalizeFields
