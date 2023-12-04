require_relative './common'

module Day3
  class Point < Value
    const :x, Integer
    const :y, Integer

    validate do
      unless x >= 0
        errors.add(:x, "negative x!")
      end

      unless y >= 0
        errors.add(:y, "negative y!")
      end
    end
  end

  class Part < Value
    const :symbol, String
    const :points, T::Set[Point]

    def adjacent?(other)
#      log(op: :adjacent?, part: self.serialize, other: other.serialize)
      points.intersect?(other.points)
    end
  end

  class PartNumber < Value
    const :number, Integer
    const :points, T::Set[Point]
  end

  class Schematic < Grid
    const :parts, T::Array[Part], default: []
    const :part_numbers, T::Array[PartNumber], default: []

    prop :digit_buffer, T::Array[String], default: []
    prop :digit_buffer_start_index, T.nilable(Integer)

    def clear_digit_buffer
      self.digit_buffer = []
      self.digit_buffer_start_index = nil
    end

    def handle_char(char, x, y)
      if char =~ /\d/
        self.digit_buffer << char
        self.digit_buffer_start_index ||= x
      else
        if self.digit_buffer.length > 0
          points = (0..digit_buffer.length - 1).map do |i| 
            Point.new(x: digit_buffer_start_index + i, y: y)
          end

          part_number = PartNumber.new(
            number: digit_buffer.join('').to_i,
            points: Set.new(points)
          )
 
          self.part_numbers << part_number

#          log(op: :new_part_number, part_number: part_number.serialize)
          clear_digit_buffer
        end
        
        if char != '.'
          points = Set.new({})
  
#          log(op: :detected_part, x: char_index, y: line_index, char: char)
  
          [-1, 0, 1].each do |x_offset|
            [-1, 0, 1].each do |y_offset|
              next if y + y_offset >= height
              next if x + x_offset >= width
              
              points.add(Point.new(x: x + x_offset, y: y + y_offset))
            rescue ActiveModel::ValidationError
              # pass
            end
          end
          part = Part.new(
            symbol: char,
            points: points
          )

          self.parts << part

#         log(op: :new_part, part: part.serialize)
        end
      end      
    end

    def after_each_line(line_index)
      if digit_buffer.length > 0
        points = (0..digit_buffer.length - 1).map do |i| 
          Point.new(x: digit_buffer_start_index + i, y: line_index)
        end
        part_number = PartNumber.new(
          number: digit_buffer.join('').to_i,
          points: Set.new(points)
        )
        self.part_numbers << part_number
      end

      clear_digit_buffer
    end

    def sum!
      sum = 0
      part_numbers.each do |part_number|
        parts.each do |part|
          if part.adjacent?(part_number)
            sum += part_number.number
          end
        end
      end
      sum
    end

    def gear_ratio!
      sum = 0
      parts.each do |part|
        adjacency = []
        part_numbers.each do |part_number|
          if part.adjacent?(part_number)
            adjacency << part_number
          end
        end

        if adjacency.length == 2
          sum += adjacency.first.number * adjacency.last.number
        end
      end

      sum
    end
  end

  class TestPart1 < Minitest::Test
    EXAMPLE = File.read(File.expand_path("./data/day_3_example.txt"))
    INPUT = File.read(File.expand_path("./data/day_3_input.txt"))

    def test_example
      assert_equal(4361, Schematic.parse(EXAMPLE).sum!)
    end

    def test_input
      assert_equal(525119, Schematic.parse(INPUT).sum!)
    end
  end

  class TestPart2 < Minitest::Test
    EXAMPLE = File.read(File.expand_path("./data/day_3_example.txt"))
    INPUT = File.read(File.expand_path("./data/day_3_input.txt"))

    def test_example
      assert_equal(467835, Schematic.parse(EXAMPLE).gear_ratio!)
    end

    def test_input
      assert_equal(76504829, Schematic.parse(INPUT).gear_ratio!)
    end
  end
end

