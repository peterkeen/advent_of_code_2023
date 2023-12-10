require_relative './common'

module Day09
  class OASIS < Value
    const :histories, T::Array[T::Array[Integer]]

    def self.parse(input)
      histories = input.strip.split(/\n/).map do |line|
        line.strip.split(/\s/).map(&:to_i)
      end

      new(histories: histories)
    end

    def diffs(sequence)
      (0..(sequence.length)).map do |i|
        a = sequence[i]
        b = sequence[i + 1]
        log(i: i, a: a, b: b)
        next if b.nil?

        b - a
      end.compact
    end

    def part_one!
      sum = 0
      histories.each do |sequence|
        log(op: :start, seq: sequence)
        d = [sequence, diffs(sequence)]

        while d[-1].uniq != [0]
          next_d = diffs(d[-1])
          d << next_d
        end

        log(op: :extrapolate, seq: sequence, d: d)

        i = d.length - 1
        while i >= 0
          a = d[i-1][-1]
          b = d[i][-1]
          next_val = a + b
          log(d: d[i], i: i, a: a, b: b, next_val: next_val)

          d[i-1] << next_val
          i = i - 1 
        end

        sum += d[0][-1]
      end

      sum
    end

    def part_two!
      sum = 0
      histories.each do |sequence|
        log(op: :start, seq: sequence)
        d = [sequence, diffs(sequence)]

        while d[-1].uniq != [0]
          next_d = diffs(d[-1])
          d << next_d
        end

        log(op: :extrapolate, seq: sequence, d: d)

        i = d.length - 1
        while i >= 0
          a = d[i-1][0]
          b = d[i][0]
          next_val = a - b
          log(d: d[i], i: i, a: a, b: b, next_val: next_val)

          d[i-1].unshift next_val
          i = i - 1 
        end

        sum += d[0][0]
      end

      sum
    end    
  end

  class Test < Minitest::Test
    def setup
      @example, @input = read_data('09')
    end

    # def test_part_one_example
    #   assert_equal(114, OASIS.parse(@example).part_one!)
    # end

    # def test_part_one_input
    #   assert_equal(1696140818, OASIS.parse(@input).part_one!)
    # end

    def test_part_two_example
      assert_equal(2, OASIS.parse(@example).part_two!)
    end

    def test_part_two_input
      assert_equal(1152, OASIS.parse(@input).part_two!)
    end            
  end
end
