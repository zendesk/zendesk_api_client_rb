require 'optparse'
require 'logger'

begin
  OptionParser.new do |opts|
    opts.banner = "Usage: zendesk c[onsole] [options]"

    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
      config["logger.level"] = v ? Logger::INFO : Logger::WARN
    end

    opts.on("-c", "--config FILE", "Load a config file") do |c|
      config.replace(YAML.load_file(c))
    end

    opts.on("-u", "--username USER", "Sets basic auth username") do |u|
      config["username"] = u
    end

    opts.on("-p", "--password PASS", "Sets basic auth password") do |p|
      config["password"] = p
    end

    opts.on("-a", "--api URL", "Sets api url") do |a|
      config["url"] = a
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

    opts.on_tail("--version", "Show version") do
      puts Zendesk::VERSION
      exit
    end
  end.parse!
rescue OptionParser::MissingArgument => e
  puts e.message
  exit
end
