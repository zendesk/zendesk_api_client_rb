class ZendeskAPI::Collection
  def /(id)
    if id == ZendeskAPI::Console::ZD_DIRUP
      if @collection_path.length == 1
        @client
      else
        @collection_path.shift
        self
      end
    elsif id.is_a?(Fixnum)
      if loaded?
        detect {|obj| obj.id == id}
      else
        find(:id => id)
      end
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

  def format_headers
    @resource_class.format_headers
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

  def format_headers
    ["resource name"]
  end
end

class ZendeskAPI::Data
  def /(method)
    if method == ZendeskAPI::Console::ZD_DIRUP
      if association.options.parent
        association.options.parent
      elsif (res = @client.send(self.class.resource_name)).loaded?
        res
      else
        ZendeskAPI::Collection.new(@client, self.class)
      end
    else
      send(method)
    end
  end

  class << self
    def format(client)
      if client.send(resource_name).loaded?
        ["@#{resource_name}"]
      else
        [resource_name]
      end
    end
  end
end

class ZendeskAPI::Resource
  class << self
    def format_headers
      [:id, :created_at]
    end
  end

  def format
    [id, created_at]
  end
end
