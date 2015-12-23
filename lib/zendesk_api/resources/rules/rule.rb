module ZendeskAPI
  class Rule < Resource
    # TODO abstract base class?
    self.resource_name = 'rules'
    self.singular_resource_name = 'rule'

    private

    def attributes_for_save
      to_save = [:conditions, :actions, :output].inject({}) {|h,k| h.merge(k => send(k))}
      { self.class.singular_resource_name.to_sym => attributes.changes.merge(to_save) }
    end
  end
end
