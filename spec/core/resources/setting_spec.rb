describe ZendeskAPI::Setting do
  # Settings arrive as parsed JSON, so the top-level keys are strings.
  describe "#initialize" do
    context "with a namespaced (Hash) setting" do
      subject do
        described_class.new(double, "lotus" => {"keyboard_shortcuts_enabled" => true})
      end

      it "records the root key in #on" do
        expect(subject.on).to eq("lotus")
      end

      it "hoists the nested hash up to the root attributes" do
        expect(subject.keyboard_shortcuts_enabled).to eq(true)
      end
    end

    context "with a top-level array setting (e.g. agent_home_pinned_views)" do
      subject do
        described_class.new(double, "agent_home_pinned_views" => [1, 2, 3])
      end

      it "does not raise (regression: no implicit conversion of Array into Hash)" do
        expect { subject }.not_to raise_error
      end

      it "records the root key in #on" do
        expect(subject.on).to eq("agent_home_pinned_views")
      end

      it "keeps the array accessible under the root key" do
        expect(subject.agent_home_pinned_views).to eq([1, 2, 3])
      end

      it "is not considered changed when left untouched, so a bulk save skips it" do
        expect(subject.changed?).to eq(false)
      end
    end

    context "with a top-level scalar setting" do
      subject do
        described_class.new(double, "shared_views_order" => "unset")
      end

      it "does not raise and keeps the value under the root key" do
        expect { subject }.not_to raise_error
        expect(subject.shared_views_order).to eq("unset")
      end
    end
  end
end
