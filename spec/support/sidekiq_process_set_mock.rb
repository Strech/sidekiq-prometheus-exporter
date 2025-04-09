# frozen_string_literal: true

require 'forwardable'

class SidekiqProcessSetMock
  extend Forwardable
  include Enumerable

  def_delegator :@processes, :each

  def initialize(processes)
    @processes = processes
  end

  def leader
    raise NotImplementedError, 'please do not use this method without stub'
  end
end
