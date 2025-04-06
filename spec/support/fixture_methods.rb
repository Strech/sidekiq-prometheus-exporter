# frozen_string_literal: true

module FixtureMethods
  def fixture(name)
    File.read(File.expand_path("./fixtures/#{name}.txt", __dir__))
  end
end
