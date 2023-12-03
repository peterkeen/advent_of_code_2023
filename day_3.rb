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

    def hash
      @hash ||= [x,y].hash
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

  class Schematic < Value
    const :parts, T::Array[Part], default: []
    const :part_numbers, T::Array[PartNumber], default: []
    const :width, Integer
    const :height, Integer

    def self.parse(input)
      lines = input.split(/\n/)
      width = lines[0].length
      height = lines.length

      obj = new(width: width, height: height)

      lines.each_with_index do |line, line_index|
        line = line.strip

        digit_buffer = []
        digit_buffer_start_char = nil

        line.split('').each_with_index do |char, char_index|
          if char =~ /\d/
            digit_buffer << char
            digit_buffer_start_char ||= char_index
          else
            if digit_buffer.length > 0
              points = (0..digit_buffer.length - 1).map do |i| 
                Point.new(x: digit_buffer_start_char + i, y: line_index)
              end

              part_number = PartNumber.new(
                number: digit_buffer.join('').to_i,
                points: Set.new(points)
              )
 
              obj.part_numbers << part_number

#              log(op: :new_part_number, part_number: part_number.serialize)
              digit_buffer = []
              digit_buffer_start_char = nil
            end
            
            if char != '.'
              points = Set.new({})
  
#              log(op: :detected_part, x: char_index, y: line_index, char: char)
  
              [-1, 0, 1].each do |x_offset|
                [-1, 0, 1].each do |y_offset|
                  next if line_index + y_offset >= height
                  next if char_index + x_offset >= width
                  
                  points.add(Point.new(x: char_index + x_offset, y: line_index + y_offset))
                rescue ActiveModel::ValidationError
                  # pass
                end
              end
              part = Part.new(
                symbol: char,
                points: points
              )

              obj.parts << part

#             log(op: :new_part, part: part.serialize)
            end
          end
        end
        if digit_buffer.length > 0
          points = (0..digit_buffer.length - 1).map do |i| 
            Point.new(x: digit_buffer_start_char + i, y: line_index)
          end
          part_number = PartNumber.new(
            number: digit_buffer.join('').to_i,
            points: Set.new(points)
          )
          obj.part_numbers << part_number
        end
      end

      obj
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

