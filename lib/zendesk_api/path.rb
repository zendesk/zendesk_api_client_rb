class Path < Struct.new(:fragment)
  def format(options)
    fragment % Hashie.symbolize_keys(options.to_hash)
  end

  # May raise KeyError?
  def to_s
    format({})
  end

  def matches?(options)
    format(options)
    true
  rescue KeyError
    false
  end
end
