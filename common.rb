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
    serialize.hash
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
