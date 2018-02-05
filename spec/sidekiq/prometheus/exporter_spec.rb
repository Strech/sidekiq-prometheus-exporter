RSpec.describe Sidekiq::Prometheus::Exporter do
  it "has a version number" do
    expect(Sidekiq::Prometheus::Exporter::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
