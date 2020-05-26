require "array_enum/version"
require "array_enum/subset_validator"
require "array_enum/railtie" if defined?(Rails::Railtie)
require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/string/inflections"

module ArrayEnum
  MISSING_VALUE_MESSAGE = "%{value} is not a valid value for %{attr}".freeze
  private_constant :MISSING_VALUE_MESSAGE

  def array_enum(attr_name, mapping, casting: nil)
    attr_symbol = attr_name.to_sym
    mapping_hash = ActiveSupport::HashWithIndifferentAccess.new(mapping)

    define_singleton_method(attr_name.to_s.pluralize) do
      mapping_hash
    end

    [['with', '@>'], ['with_any', '&&']].each do |with, op|
      define_singleton_method("#{with}_#{attr_name}".to_sym) do |values|
        db_values = Array(values).map do |value|
          mapping_hash[value] || raise(ArgumentError, MISSING_VALUE_MESSAGE % {value: value, attr: attr_name})
        end
        cast = "::#{casting.to_s}[]" unless casting.nil?
        where("#{attr_name} #{op} ARRAY[:db_values]#{cast}", db_values: db_values)
      end
    end

    define_method(attr_symbol) do
      Array(self[attr_symbol]).map { |value| mapping_hash.key(value) }
    end

    define_method("#{attr_name}=".to_sym) do |values|
      self[attr_symbol] = Array(values).map do |value|
        mapping_hash[value] || raise(ArgumentError, MISSING_VALUE_MESSAGE % {value: value, attr: attr_name})
      end.uniq
    end
  end
end
