require_relative '../hylafax_status_monitor'

describe "#get_output" do
  context "given a good output" do
    it "returns just the status" do
      text = "HylaFAX scheduler on music.lan: Running\nModem ttyUSB1 (96021889): Running and idle"
      get_output(text).should eq("Running and idle")
    end
  end

  context "given a bad output" do
    it "returns just the status" do
      text = "Can not reach service hylafax at host \"localhost\"."
      get_output(text).should eq(nil)
    end
  end
end

# describe "#status" do
#   context "initialize server" do
#     it "returns good" do
#       status()
#     end
#   end
# end
