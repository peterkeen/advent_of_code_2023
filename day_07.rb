require_relative './common'

module Day07
  PART_ONE_LABELS = %w[A K Q J T 9 8 7 6 5 4 3 2].reverse
  PART_ONE_LABEL_INDEX = PART_ONE_LABELS.map.with_index { |l, i| [l, i] }.to_h

  PART_TWO_LABELS = %w[A K Q T 9 8 7 6 5 4 3 2 J].reverse
  PART_TWO_LABEL_INDEX = PART_TWO_LABELS.map.with_index { |l, i| [l, i] }.to_h  

  class Hand < Value
    const :cards, T::Array[String]
    const :bid, Integer
    
    def self.parse(input)
      cards, bid = input.strip.split(/\s/, 2)
      new(
        cards: cards.split(''),
        bid: bid.to_i
      )
    end

    def n_of_a_kind?(n, jokers_wild, skip: [])
      all_groups = cards.group_by { |c| c }.sort_by { |c, g| g.length }.map(&:last)

      skip.flatten.uniq.compact.each do |s|
        i = all_groups.index { |g| g.first == s }
        all_groups.delete_at(i) if i
      end

      if jokers_wild
        jokers_index = all_groups.index { |g| g.first == 'J' }
        if jokers_index
          jokers = all_groups.delete_at(jokers_index)

          if all_groups.length == 0
            all_groups = [jokers]
          else
            add_to_label = all_groups.sort_by { |g| g.length }.last.first
            add_to_group_index = all_groups.index { |g| g.first == add_to_label }
            all_groups[add_to_group_index] += jokers
          end
        end
      end

      groups = all_groups.select { |g| g.length == n }
      return groups if groups.length > 0
      nil
    end

    def full_house?(jokers_wild)
      three = n_of_a_kind?(3, jokers_wild)
      two = n_of_a_kind?(2, false, skip: [three&.first]) # we already used any available jokers

      return [three, two] if three && two
      nil
    end

    def two_pair?(jokers_wild)
      pairs = n_of_a_kind?(2, jokers_wild)
      return true if pairs && pairs.length == 2
      nil
    end

    def one_pair?(jokers_wild)
      pairs = n_of_a_kind?(2, jokers_wild)
      return true if pairs && pairs.length == 1
      nil
    end      

    def sort_key(label_index, jokers_wild=false)
      type = if n_of_a_kind?(5, jokers_wild)
               7
             elsif n_of_a_kind?(4, jokers_wild)
               6
             elsif full_house?(jokers_wild)
               5
             elsif n_of_a_kind?(3, jokers_wild)
               4
             elsif two_pair?(jokers_wild)
               3
             elsif one_pair?(jokers_wild)
               2
             else
               1
             end
      [type] + cards.map {|c| label_index[c]}
    end
  end

  class Game < Value
    const :hands, T::Array[Hand]

    def self.parse(input)
      new(hands: input.split(/\n/).map { |h| Hand.parse(h) })
    end

    def part_one!
      h = hands.sort_by { |hand| hand.sort_key(PART_ONE_LABEL_INDEX) }
      h.map.with_index {|h, i| h.bid * (i + 1)}.sum
    end

    def part_two!
      h = hands.sort_by { |hand| hand.sort_key(PART_TWO_LABEL_INDEX, true) }

      h.map.with_index do |h, i| 
        h.bid * (i + 1)
      end.sum
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
      assert_equal(5905, Game.parse(@example).part_two!)
    end

    def test_part_two_input
      assert_equal(250057090, Game.parse(@input).part_two!)
    end    
  end
end
