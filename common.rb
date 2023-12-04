require 'minitest/autorun'
require 'sorbet-runtime'
require 'active_model'

SHOULD_LOG = ENV.fetch('SHOULD_LOG', "false") == "true"

module Log
  extend T::Helpers

  module ClassMethods
    def log(**kwargs)
      return unless should_log?
      str = kwargs.map {|k,v| "#{k}=#{v}"}.join(" ")
      warn("#{self}: #{str}")
    end

    def should_log?
      return SHOULD_LOG
    end
  end

  def log(**kwargs)
    self.class.log(**kwargs)
  end

  mixes_in_class_methods(ClassMethods)
end

class Value < T::InexactStruct
  include Log
  include ActiveModel::Validations  
  extend ActiveModel::Callbacks

  define_model_callbacks :initialize

  after_initialize :validate!

  def self.from_hash(hash={})
    run_callbacks :initialize do
      super(hash)
    end
  end

  def initialize(*args, **kwargs)
    run_callbacks :initialize do
      super
    end
  end

  def ==(other)
    serialize == other.serialize
  end
  alias_method :eql?, :==

  def hash
    @hash ||= serialize.hash
  end
end

class Service < Value
  extend T::Sig
  extend T::Helpers

  def self.call(**kwargs)
    new(**kwargs).call
  end

  sig { abstract.void }
  def call
  end
end

class Grid < Value
  const :width, Integer
  const :height, Integer

  def self.parse(input)
    lines = input.split(/\n/)
    width = lines[0].length
    height = lines.length

    obj = new(width: width, height: height)

    lines.each_with_index do |line, line_index|
      line = line.strip

      line.split('').each_with_index do |char, char_index|
        obj.handle_char(char, char_index, line_index)
      end

      obj.after_each_line(line_index)
    end

    obj
  end
end

class GameLine < Value
  extend T::Sig
  extend T::Helpers

  const :type, String
  const :id, Integer
  const :line, String

  sig { params(input_line: String).returns(T.attached_class) }
  def self.parse(input_line)
    game_ident, rest = input_line.strip.split(/:/, 2)
    game_type, game_id = game_ident.split(/\s+/, 2)

    new(type: game_type, id: game_id.to_i, line: rest).tap do |obj|
      obj.parse
    end
  end

  sig { void }
  def parse
  end
end

class LineGame < Value
  extend T::Sig
  extend T::Helpers

  const :lines, T::Array[GameLine], default: []

  sig { abstract.returns(T.class_of(GameLine)) }
  def self.game_line_class
  end

  sig { params(input: String).returns(T.attached_class) }
  def self.parse(input)
    new.tap do |obj|
      input.strip.split(/\n/).each do |line|
        obj.lines << game_line_class.parse(line.strip)
      end
    end
  end
end
