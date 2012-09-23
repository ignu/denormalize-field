require 'active_record'

module DenormalizeFields
  def denormalizes(hash)
  end
end

ActiveRecord::Base.send :extend, DenormalizeFields
