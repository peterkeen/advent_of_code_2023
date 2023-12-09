require_relative './common'

module Day08
  class Graph < Value
    const :path, T::Array[Integer]
    const :nodes, T::Array[T::Array[Integer]]

    const :start_nodes, T::Array[Integer]
    const :end_nodes, T::Array[Integer]

    def self.parse(input)
      path_str, nodes_str = input.strip.split(/\n\n/, 2)
      path = path_str.strip.split('').map { |p| p == 'L' ? 0 : 1 }

      node_index = {}
      raw_nodes = []
      start_nodes = []
      end_nodes = []

      node_regex = /(\w{3}) = \((\w{3}), (\w{3})\)/

      nodes_str.strip.split(/\n/).sort.each do |node|
        m = node.match(node_regex)
        raise "no match" if m.nil?

        n = m[1]
        l = m[2]
        r = m[3]

        log(n: n, l: l, r: r)

        raw_nodes << [l, r]
        insert_index = raw_nodes.length - 1

        if n.end_with?('A')
          start_nodes << insert_index
        elsif n.end_with?('Z')
          end_nodes << insert_index
        end

        node_index[n] = insert_index
      end

      nodes = []
      raw_nodes.each do |l,r|
        nodes << [node_index[l], node_index[r]]
      end

      new(
        path: path,
        nodes: nodes,
        start_nodes: start_nodes,
        end_nodes: end_nodes
      )
    end

    def part_one!
      count = 0
      cur = 0

      log(s: serialize)

      while count < 100000
        break if cur == nodes.length - 1
        path.each do |path|
          count += 1
          cur = nodes[cur][path]
          break if cur == nodes.length - 1
        end
      end

      count
    end

    def part_two!
      counts = []

      start_nodes.each do |node|
        count = 0

        cur = node

        while count < 100000
          break if end_nodes.include?(cur)
          path.each do |path|
            break if end_nodes.include?(cur)
            count += 1
            cur = nodes[cur][path]
          end
        end
        counts << count
      end
      counts.reduce(1, :lcm)
    end
  end

  class TestOne < Minitest::Test
    def setup
      @example, @input = read_data('08')
    end

    # def test_example
    #   assert_equal(6, Graph.parse(@example).part_one!)
    # end

    # def test_input
    #   assert_equal(19241, Graph.parse(@input).part_one!)
    # end
  end

  class TestTwo < Minitest::Test
    def setup
      _, @input = read_data('08')
      @example = <<-HERE
        LR

        11A = (11B, XXX)
        11B = (XXX, 11Z)
        11Z = (11B, XXX)
        22A = (22B, XXX)
        22B = (22C, 22C)
        22C = (22Z, 22Z)
        22Z = (22B, 22B)
        XXX = (XXX, XXX)
      HERE
    end

    def test_example
      assert_equal(6, Graph.parse(@example).part_two!)
    end

    def test_input
      assert_equal(-1, Graph.parse(@input).part_two!)
    end
  end
end
