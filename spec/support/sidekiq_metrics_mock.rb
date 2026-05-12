# frozen_string_literal: true

module SidekiqMetricsMock
  class Query
    def initialize(**); end

    def top_jobs(**_)
      raise NotImplementedError, 'please do not use this method without stub'
    end
  end

  QueryResult = Struct.new(:job_results)
  JobResult = Struct.new(:totals)
end
