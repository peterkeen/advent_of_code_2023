require_relative './common'

module Day05
  EXAMPLE, INPUT = read_data('05')

  class Mapping < Value
    const :dest_start, Integer
    const :source_start, Integer
    const :range_length, Integer

    def self.parse(input)

      dest_start, source_start, range_length = input.strip.split(/\s+/)

      new(
        dest_start: dest_start.to_i,
        source_start: source_start.to_i,
        range_length: range_length.to_i
      )
    end

    def source_range
      @source_range ||= Range.new(source_start, source_start + range_length)
    end

    def destination_range
      @destination_range ||= Range.new(dest_start, dest_start + range_length)
    end

    def match_source?(source)
      source_range.include?(source)
    end

    def match_destination?(destnation)
      destination_range.include?(destination)
    end

    def destination(source)
      offset = source - source_start
      dest_start + offset
    end

    def source(destination)
      offset = destination - dest_start
      source_start + offset
    end
  end

  class Map < Value
    const :title, String
    const :mappings, T::Array[Mapping], default: []

    def self.parse(input)
      lines = input.strip.split(/\n/)
      title = lines.shift

      mappings = lines.map { |l| Mapping.parse(l) }

      new(
        title: title,
        mappings: mappings
      )
    end

    def destination(source)
      mapping = mappings.detect { |m| m.match_source?(source) }
      if mapping
        return mapping.destination(source)
      else
        return source
      end
    end

    def source(destination)
      mapping = mappings.detect { |m| m.match_destination?(destination) }
      if mapping
        return mapping.source(destination)
      else
        return destination
      end
    end

    def self.reduce(a, b)
      obj = new
    end
  end

  class Almanac < Value
    const :seeds, T::Array[Integer], default: []
    const :maps, T::Array[Map], default: []

    def self.parse(input)
      parts = input.strip.split("\n\n")
      seeds = parts.shift.split(/:\s+/, 2).last.split(/\s+/).map(&:to_i)

      maps = parts.map { |p| Map.parse(p) }

      new(
        seeds: seeds,
        maps: maps
      )
    end

    def location_for_seed(seed)
      cur = seed.dup

      maps.each do |map|
        cur = map.destination(cur)
      end

      cur
    end

    def seed_for_location(location)
      cur = location.dup

      maps.reverse.each do |map|
        cur = map.source(cur)
      end

      cur
    end

    def part_one!
      seeds.map { |s| location_for_seed(s) }.min
    end


=begin
the problem is that the brute force navigation way is not computationally feasible
the spoiler threads talk about reducing the maps until you have seed => location

- convert seeds to a Map
- write a reduce function that takes two maps A and B and produces a map with sources from A and destinations from B
- reduce the maps into a single map

seed intervals:
- seed, seed, length

reduce:



=end       
    def part_two!
      min = nil

      seeds.each_slice(2) do |pair|
        r = Range.new(pair.first, pair.first + pair.last - 1)
        log(range: r, size: r.size)
        r.each do |seed|
          loc = location_for_seed(seed)

          if min.nil? || loc < min
            min = loc
          end
        end
      end

      min
    end

    def part_two_alt!
      min = nil

      seed_ranges = []
      seeds.each_slice(2) do |pair|
        seed_ranges << Range.new(pair.first, pair.first + pair.last - 1)
      end

      log(seeds: seed_ranges.sum { |r| r.size })

      # location_mappings = maps.last.mappings
      # min_location = location_mappings.min_by { |m| m.dest_start }.destination_range.first
      # max_location = location_mappings.max_by { |m| m.dest_start + m.range_length }.destination_range.last

      # location_range = Range.new(min_location, max_location)

      # location_range.each do |loc|
        
      # end

      min
    end
  end

  class Test < Minitest::Test
    def test_part_1_example
      assert_equal(35, Almanac.parse(EXAMPLE).part_one!)
    end

    def test_part_1_input
      assert_equal(199602917, Almanac.parse(INPUT).part_one!)
    end

    def test_part_2_example
      assert_equal(46, Almanac.parse(EXAMPLE).part_two!)
    end

    # def test_part_2_input
    #   assert_equal(-1, Almanac.parse(INPUT).part_two_alt!)
    # end
  end
end
