require_relative './common'

module Day4
  EXAMPLE = File.read(File.expand_path("./data/day_4_example.txt"))
  INPUT = File.read(File.expand_path("./data/day_4_input.txt"))

  class Scratchcard < GameLine
    const :winning_numbers, T::Set[Integer], factory: ->{ Set.new({}) }
    const :card_numbers, T::Set[Integer], factory: ->{ Set.new({}) }

    def parse
      winners, ours = line.split(/\s+\|\s+/, 2)

      self.winning_numbers.merge(winners.strip.split(/\s+/).map(&:to_i))
      self.card_numbers.merge(ours.strip.split(/\s+/).map(&:to_i))
    end

    def cardinality
      @cardinality ||= (winning_numbers & card_numbers).length
    end

    def score
      return 0 if cardinality == 0

      2**(cardinality - 1)
    end
  end

  class ScratchcardsGame < LineGame
    def self.game_line_class
      Scratchcard
    end

    def part_one
      lines.sum(&:score)
    end

    def part_two
      cards = lines.map { |l| 1 }

      lines.each_with_index do |card, l|
        cards[l].times do |c|
          lines[l].cardinality.times do |i|
            cards[l + i + 1] += 1
          end
        end
      end

      cards.sum
    end
  end

  class TestPart1 < Minitest::Test
    def test_example
      assert_equal(13, ScratchcardsGame.parse(EXAMPLE).part_one)
    end

    def test_input
      assert_equal(15268, ScratchcardsGame.parse(INPUT).part_one)
    end
  end

  class TestPart2 < Minitest::Test
    def test_example
      assert_equal(30, ScratchcardsGame.parse(EXAMPLE).part_two)
    end

    def test_input
      assert_equal(6283755, ScratchcardsGame.parse(INPUT).part_two)
    end
  end
end
