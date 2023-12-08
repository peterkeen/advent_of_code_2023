require_relative './common'

module Day08
  class Graph < Value
    const :path, T::Array[Integer]
    const :nodes, T::Array[T::Array[Integer]]

    def self.parse(input)
      path_str, nodes_str = input.strip.split(/\n\n/, 2)
      path = path_str.strip.split('').map { |p| p == 'L' ? 0 : 1 }

      node_index = {}
      raw_nodes = []

      node_regex = /(\w{3}) = \((\w{3}), (\w{3})\)/
      nodes_str.strip.split(/\n/).sort.each do |node|
        m = node.match(node_regex)
        raise "no match" if m.nil?

        n = m[1]
        l = m[2]
        r = m[3]

        log(n: n, l: l, r: r)

        raw_nodes << [l, r]
        node_index[n] = raw_nodes.length - 1
      end

      nodes = []
      raw_nodes.each do |l,r|
        nodes << [node_index[l], node_index[r]]
      end

      new(
        path: path,
        nodes: nodes,
      )
    end

    def part_one!
      count = 0
      cur = 0

      log(s: serialize)

      while count < 100000
        break if cur == nodes.length - 1
        path.each do |path|
#          log(op: :before, count: count, cur: cur, path: path)

          count += 1
          cur = nodes[cur][path]

#          log(op: :after, count: count, cur: cur, path: path, l: nodes.length)
          break if cur == nodes.length - 1
        end
      end

      count
    end
  end

  class Test < Minitest::Test
    def setup
      @example, @input = read_data('08')
    end

    def test_part_one_example
      assert_equal(6, Graph.parse(@example).part_one!)
    end

    def test_part_one_input
      assert_equal(19241, Graph.parse(@input).part_one!)
    end
  end
end
