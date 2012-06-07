module ZendeskAPI
  module Rescue
    def rescue_client_error(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}

      args.each do |method|
        class_eval("alias :orig_#{method} :#{method}")
        define_method method do |*args|
          begin
            send("orig_#{method}", *args)
          rescue Faraday::Error::ClientError => e
            if logger = (@client ? @client.config.logger : Kernel)
              logger.warn "#{self} - #{method}"
              logger.warn e.message
              logger.warn e.backtrace.join("\n")
              logger.warn "\t#{e.response[:body].inspect}" if e.response
            end
            opts[:with].respond_to?(:call) ? opts[:with].call : opts[:with]
          end
        end
      end
    end
  end
end
