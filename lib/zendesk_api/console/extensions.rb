class ZendeskAPI::Collection
  def /(id)
    if id.is_a?(Fixnum)
      find(:id => id)
    elsif !id.is_a?(ZendeskAPI::Collection)
      send(id)
    end
  end

  def loaded?
    @resources && @resources.any?
  end

  def to_s
    "/#{path}"
  end
end

class ZendeskAPI::Client
  GET_SUBCLASSES = lambda do |ary|
    ary.map! do |klass|
      if klass.name =~ /Resource$/
        GET_SUBCLASSES.call(klass.subclasses)
      else
        klass
      end
    end

    ary.tap(&:flatten!)
  end

  def to_s
    "/"
  end

  def self.resources
    @resources ||= GET_SUBCLASSES.call(ZendeskAPI::Data.subclasses).sort_by(&:resource_name)
  end

  def to_a
    self.class.resources
  end
end

class << ZendeskAPI::Data
  def format(client)
    if client.send(resource_name).loaded?
      "@#{resource_name}"
    else
      resource_name
    end
  end
end

class ZendeskAPI::Resource
  def format
    "#{id}\t#{created_at}"
  end
end
