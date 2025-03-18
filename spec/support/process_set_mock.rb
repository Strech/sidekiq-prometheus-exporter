class ProcessSetMock
  include Enumerable

  attr_reader :leader

  def initialize(processes, leader)
    @processes = processes
    @leader = leader
  end

  def each(&block)
    @processes.each(&block)
  end
end
