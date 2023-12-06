require_relative './common'

module Day06
  EXAMPLE, INPUT = read_data('06')

  class Race < Value
    const :time, Integer
    const :distance_record, Integer

    def ways_to_beat_record
      ways = 0
      (0..time).each do |t|
        distance = (time - t) * t
        if distance > distance_record
          ways += 1
        end
      end

      ways
    end
  end

  class RaceSet < Value
    const :races, T::Array[Race]

    def self.parse(input, ignore_spaces=false)
      times, distances = input.strip.split(/\n/).map { |p| parse_line(p, ignore_spaces) }

      if times.length != distances.length
        raise "Invalid input!"
      end

      races = times.zip(distances).map { |t, d| Race.new(time: t, distance_record: d) }

      new(races: races)
    end

    def self.parse_line(line, ignore_spaces)
      parts = line.split(/\s+/).drop(1)
      if ignore_spaces
        parts = [parts.join('')]
      end
      parts.map(&:to_i)
    end

    def part_one!
      races.map { |r| r.ways_to_beat_record }.reject(&:zero?).inject(:*) || 0
    end
  end

  class Test < Minitest::Test
    def test_part_one_example
      assert_equal(288, RaceSet.parse(EXAMPLE).part_one!)
    end

    def test_part_one_input
      assert_equal(2612736, RaceSet.parse(INPUT).part_one!)
    end

    def test_part_two_example
      assert_equal(71503, RaceSet.parse(EXAMPLE, true).part_one!)
    end

    def test_part_two_input
      assert_equal(29891250, RaceSet.parse(INPUT, true).part_one!)
    end    
  end
end
