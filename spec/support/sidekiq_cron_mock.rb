# frozen_string_literal: true

module SidekiqCronMock
  class Job
    def self.count
      raise NotImplementedError, 'please do not use this method without stub'
    end
  end
end
