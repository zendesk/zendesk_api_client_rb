module Zendesk
  module Rescue
    def rescue_client_error(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |method|
        class_eval("alias :orig_#{method} :#{method}")
        define_method method do |*args|
          begin
            send("orig_#{method}", *args)
          rescue Faraday::Error::ClientError => e
            puts "#{self} - #{method}"
            puts e.message
            puts e.backtrace
            puts "\t#{e.response[:body].inspect}" if e.response
            opts[:with].respond_to?(:call) ? opts[:with].call : opts[:with]
          end
        end
      end
    end
  end
end
