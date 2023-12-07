require_relative './common'

module Day07
  class Hand < Value
    LABELS = %w[A K Q J T 9 8 7 6 5 4 3 2].reverse
    PART_ONE_LABEL_INDEX = LABELS.map.with_index { |l, i| [l, i] }.to_h

    const :cards, T::Array[String]
    const :bid, Integer
    
    def self.parse(input)
      cards, bid = input.strip.split(/\s/, 2)
      new(
        cards: cards.split(''),
        bid: bid.to_i
      )
    end

    def n_of_a_kind?(n)
      groups = cards.group_by { |c| c }.sort_by { |c, g| g.length }.map(&:last).select { |g| g.length == n }
      return groups.map(&:first) if groups.length > 0
    end

    def full_house?
      three = n_of_a_kind?(3)
      two = n_of_a_kind?(2)

      return [three, two] if three && two
      nil
    end

    def two_pair?
      pairs = n_of_a_kind?(2)
      return true if pairs && pairs.length == 2
      nil
    end

    def one_pair?
      pairs = n_of_a_kind?(2)
      return true if pairs && pairs.length == 1
      nil
    end      

    def sort_key
      type = if n_of_a_kind?(5)
               7
             elsif n_of_a_kind?(4)
               6
             elsif full_house?
               5
             elsif n_of_a_kind?(3)
               4
             elsif two_pair?
               3
             elsif one_pair?
               2
             else
               1
             end
      [type] + cards.map {|c| PART_ONE_LABEL_INDEX[c]}
    end
  end

  class Game < Value
    const :hands, T::Array[Hand]

    def self.parse(input)
      new(hands: input.split(/\n/).map { |h| Hand.parse(h) })
    end

    def part_one!
      h = hands.sort_by(&:sort_key)
      h.map.with_index {|h, i| h.bid * (i + 1)}.sum
    end
  end

  class Test < Minitest::Test
    def setup
      @example, @input = read_data('07')
    end

    def test_part_one_example
      assert_equal(6440, Game.parse(@example).part_one!)
    end

    def test_part_one_input
      assert_equal(248812215, Game.parse(@input).part_one!)
    end

    def test_part_two_example
      assert_equal(5905, Game.parse(@example).part_one!)
    end
  end
end
