class Keyword < ActiveRecord::Base
  serialize :arguments

  def required_args
    arguments.select{ |x| !x.include?('=') }
  end
end
