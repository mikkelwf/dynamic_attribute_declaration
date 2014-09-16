require 'active_record'

load File.dirname(__FILE__) + '/schema.rb'

class Phone < ActiveRecord::Base
  attr_accessor :state

  def validator value
    state == value
  end
end