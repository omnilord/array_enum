$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record"
require "array_enum"
require "minitest/autorun"

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  host: "localhost",
  database: "array_enum_test"
)
ActiveRecord::Base.connection.execute("SELECT 1") # catch db errors early

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.integer :favourite_colors, array: true
  end

  create_table :companies, force: true do |t|
    t.text :favourite_colors, array: true
  end
end

class User < ActiveRecord::Base
  extend ArrayEnum

  array_enum :favourite_colors, {"red" => 1, "blue" => 2, "green" => 3}
end

class Company < ActiveRecord::Base
  extend ArrayEnum

  array_enum :favourite_colors, {red: "red", blue: "blue", green: "green"}, casting: 'text'
end

# Mimic constant assigment from railtie
SubsetValidator = ArrayEnum::SubsetValidator
