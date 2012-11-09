# Modified from DoubleDoc
# https://github.com/staugaard/double_doc/blob/master/lib/double_doc/html_renderer.rb
module ZendeskAPI::Server
  class HtmlRenderer
    def self.markdown
      @markdown ||= Redcarpet::Markdown.new(RedcarpetRenderer, :fenced_code_blocks => true, :no_intra_emphasis => true, :tables => true)
    end

    def self.render(text)
      markdown.render(text)
    end

    def self.generate_id(text)
      text.strip.downcase.gsub(/[\s,]+/, '-')
    end

    class RedcarpetRenderer < Redcarpet::Render::HTML
      attr_reader :headers

      def icons
        <<-END
          <i class=\"header-icon icon-plus\"></i>
          <i class=\"header-icon icon-minus hide\"></i>
        END
      end

      def header(text, level)
        top_level = [2, 3].include?(level)
        id = HtmlRenderer.generate_id(text)

        @headers ||= []
        @headers << id if top_level

        "<h#{level} id=\"#{id}\">
          #{icons if top_level}
          #{text}
        </h#{level}>"
      end

      def block_code(code, language)
        # CodeRay doesn't know HTTP
        language = "json" if language == "http"

        mod = {}

        json = nil

        if language
          if code.start_with?("curl")
            if code =~ %r[(https://{subdomain}.zendesk.com/api/v2/.*.json(\?(\w+={.+})+ )?)]
              example = true

              mod["class"] = "example"
              mod["data-url"] = $1.strip

              # This grabs the -d parameter
              # ...
              if code.include?(" -d ")
                str_begin = code.index(/['"]/, code.index(" -d "))

                chars = code[str_begin..-1].chars.to_a
                str_end = nil

                chars[1..-1].each_with_index do |char, i|
                  if char == chars[0] && chars[i - 1] != "\\"
                    str_end = i
                    break
                  end
                end

                mod["data-json"] = code.slice(str_begin + 1..(str_begin + str_end)) if str_end
              end

              if code =~ /-X (PUT|POST|GET|DELETE)/
                mod["data-method"] = $1
              end
            end
          end

          code = CodeRay.scan(code, language).html(:wrap => nil)
        end

        mod = mod.inject([]) {|str,(k,v)| str.push("#{k}='#{v}'")}.join(" ")

        if example
          <<-END
            <button class="btn example" title="Fill in the form with this example">
              <i class="icon icon-pencil"></i>
            </button>
            <pre #{mod}>#{code}</pre>
          END
        else
          "<pre>#{code}</pre>"
        end
      end
    end
  end
end
