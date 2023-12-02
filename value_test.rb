require_relative './common'

class ValueTest < Minitest::Test
  class ValueWithValidation < Value
    const :amount, Integer

    validate :validate_amount

    def validate_amount
      errors.add(:amount, "not ten!") if amount != 10
    end
  end

  def test_callbacks
    assert(ValueWithValidation.new(amount: 10).valid?)

    assert_raises(ActiveModel::ValidationError) do
      ValueWithValidation.new(amount: 11)
    end
  end

  def test_equality
    assert_equal(ValueWithValidation.new(amount: 10), ValueWithValidation.new(amount: 10))
  end
end
