class ZendeskAPI::DataNamespaceTest; end

describe ZendeskAPI::DataNamespace do
  describe "descendants" do
    let(:target_klass) { ZendeskAPI::DataNamespaceTest }
    it "adds class to its descendants list when included" do
      expect(ZendeskAPI::DataNamespace.descendants).not_to include(target_klass)
      expect { target_klass.send(:include, ZendeskAPI::DataNamespace) }
        .to change { ZendeskAPI::DataNamespace.descendants.count }.by(1)
      expect(ZendeskAPI::DataNamespace.descendants).to include(target_klass)
    end
  end
end
