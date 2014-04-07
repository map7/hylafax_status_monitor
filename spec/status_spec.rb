require_relative '../lib/status.rb'

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

describe "#status" do
  context "initialize server" do
    it "returns true" do
      status("Initializing server").should eq(true)
    end
  end

  context "Running and idle" do
    it "returns true" do
      status("Running and idle").should eq(true)
    end
  end

  context "Sending Job 654" do
    it "returns true" do
      status("Sending Job 654").should eq(true)
    end
  end

  context "Listening to rings from modem" do
    it "returns false" do
      status("Listening to rings from modem").should eq(false)
    end
  end
end

describe "#sent_status" do
  before do
    @store = PStore.new("/tmp/hylafax_status_failed.db")
  end
  
  context "fax status is bad(false)" do
    context "have already sent" do
      it "returns true" do
        @store.transaction {@store[:sent] = true}
        sent_status(false).should eq(true)
      end
    end
 
    context "hasn't sent" do
      context "store exists" do
        it "returns false" do
          @store.transaction {@store[:sent] = false}
          sent_status(false).should eq(false)
        end
      end

      context "store doesn't exist" do
        it "returns false" do
          @store.transaction {@store[:sent] = nil}
          sent_status(false).should eq(false)
        end
      end
    end 
  end

  context "fax status is good(true)" do 
    context "have already sent" do
      it "returns true" do
        @store.transaction {@store[:sent] = true}
        sent_status(true).should eq(true)
      end

      it "resets the sent status" do
        @store.transaction {@store[:sent] = true}
        sent_status(true).should eq(true)
        @store.transaction {@store[:sent].should eq(false)}
      end
    end

    context "hasn't sent" do
      it "returns false" do
        @store.transaction {@store[:sent] = false}
        sent_status(true).should eq(false)
      end
    end 
  end
  
end
