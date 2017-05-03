class Keyword < ActiveRecord::Base
  def required_args
    arguments.select{ |x| !x.include?('=') }
  end
end
