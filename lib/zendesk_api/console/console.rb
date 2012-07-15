module ZendeskAPI::Console
  def client(&blk)
    return @client if @client && blk.nil?

    @client = ZendeskAPI::Client.new do |cfg|
      config.each do |k,v|
        cfg.send("#{k}=", v)
      end if config.keys.any?
      blk.call(cfg) unless blk.nil?
    end
  end

  def help
    <<-END
This is help.
    END
  end

  def username(username)
    client.config.username = username
  end

  def password(password)
    client.config.password = password
  end

  def basic_auth(username, password)
    username(username)
    password(password)
    true
  end

  def url(url)
    client.config.url = url
  end

  %w(get post put delete).each do |verb|
    define_method verb do |*args|
      client.connection.send(verb, *args)
    end
  end

  def cd(new_path = nil)
    if new_path.class.to_s =~ /^Zendesk/
      @path = new_path
    elsif new_path.is_a?(Fixnum)
      found = path.find(:id => new_path)
      @path = found if found
    else
      @path = nil
    end

    @path
  end

  def cwd
    begin
      path
    rescue ArgumentError
      "unconfigured"
    end
  end

  def ls(*args)
    if path.respond_to?(:to_a)
      puts to_a.map {|elem|
        if elem.method(:format).arity == 1
          elem.format(client)
        else
          elem.format
        end
      }.join("\n")
    else
      methods = path.public_methods.reject do |method|
        method =~ /^orig_/ || method.to_sym == :method_missing ||
          Object.public_methods.include?(method)
      end
    end
  end

  def method_missing(*args)
    path.send(*args)
  end

  def config
    @options ||= {}
  end

  private

  def path
    @path || client
  end
end
