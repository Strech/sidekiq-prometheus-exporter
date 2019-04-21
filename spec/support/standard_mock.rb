#frozen_string_literal: true

class StandardMock
  def self.available?
    raise NotImplementedError, 'please do not use this method without stub'
  end

  def to_s
    raise NotImplementedError, 'please do not use this method without stub'
  end
end
