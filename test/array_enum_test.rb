require "test_helper"

class ArrayEnumTest < Minitest::Test
  def setup
    User.delete_all
  end

  def test_assigning_enum_values
    user = User.new(favourite_colors: ["red", "blue"])
    assert_equal ["red", "blue"], user.favourite_colors
  end

  def test_assigning_enum_values_as_symbols
    user = User.new(favourite_colors: [:red, :blue])
    assert_equal ["red", "blue"], user.favourite_colors
  end

  def test_raising_error_on_unknown_value
    error = assert_raises(ArgumentError) do
      User.new(favourite_colors: ["black"])
    end
    assert_match(/black is not a valid value for favourite_colors/, error.message)
  end

  def test_storing_values_as_integers
    user = User.create!(favourite_colors: ["red"])
    user.reload
    assert_equal "{1}", user.read_attribute_before_type_cast("favourite_colors")
  end

  # Scope with_*
  def test_quering_db_with_single_matching_value
    user = User.create!(favourite_colors: ["red"])
    assert_equal [user], User.with_favourite_colors("red")
  end

  def test_quering_db_with_single_matching_symbol_value
    user = User.create!(favourite_colors: ["red"])
    assert_equal [user], User.with_favourite_colors(:red)
  end

  def test_quering_db_by_one_of_matching_value
    user = User.create!(favourite_colors: ["red", "blue"])
    assert_equal [user], User.with_favourite_colors("red")
  end

  def test_quering_db_by_excluded_value_does_not_return_record
    User.create!(favourite_colors: ["red", "blue"])
    assert_equal [], User.with_favourite_colors("green")
  end

  def test_quering_db_by_many_values_does_not_return_record_on_excluded_value
    User.create!(favourite_colors: ["red", "blue"])
    assert_equal [], User.with_favourite_colors(["red", "green"])
  end

  def test_quering_db_by_non_existing_value_raises_error
    User.create!(favourite_colors: ["red", "blue"])
    error = assert_raises(ArgumentError) do
      User.with_favourite_colors("black")
    end
    assert_match(/black is not a valid value for favourite_colors/, error.message)
  end

  # Scope with_any_*
  def test_quering_db_with_any_single_matching_value
    user = User.create!(favourite_colors: ["red"])
    assert_equal [user], User.with_any_favourite_colors("red")
  end

  def test_quering_db_with_any_single_matching_symbol_value
    user = User.create!(favourite_colors: ["red"])
    assert_equal [user], User.with_any_favourite_colors(:red)
  end

  def test_quering_db_by_one_of_any_matching_value
    user = User.create!(favourite_colors: ["red", "blue"])
    assert_equal [user], User.with_any_favourite_colors("red")
  end

  def test_quering_db_by_any_excluded_value_does_not_return_record
    User.create!(favourite_colors: ["red", "blue"])
    assert_equal [], User.with_any_favourite_colors("green")
  end

  def test_quering_db_by_any_many_values_does_return_record_on_excluded_value
    user = User.create!(favourite_colors: ["red", "blue"])
    assert_equal [user], User.with_any_favourite_colors(["red", "green"])
  end

  # Value accessor
  def test_lists_values
    assert_equal User.favourite_colors, {"red"=>1, "blue"=>2, "green"=>3}
    assert_equal Company.favourite_colors, {"red" => "red", "blue" => "blue", "green" => "green"}
  end

  def test_values_can_be_accessed_indifferently
    assert_equal User.favourite_colors[:red], 1
    assert_equal User.favourite_colors[:blue], 2
    assert_equal User.favourite_colors[:green], 3
    assert_equal User.favourite_colors["red"], 1
    assert_equal Company.favourite_colors[:red], "red"
    assert_equal Company.favourite_colors["red"],"red"
  end

  # Casting
  def test_quering_db_with_casting_type_defined
    company = Company.create!(favourite_colors: ["red"])
    assert_equal [company], Company.with_favourite_colors("red")
  end
end
