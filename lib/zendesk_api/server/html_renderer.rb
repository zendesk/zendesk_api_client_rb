# Modified from DoubleDoc
# https://github.com/staugaard/double_doc/blob/master/lib/double_doc/html_renderer.rb
module ZendeskAPI::Server
  class HtmlRenderer
    def self.render(text)
      markdown = Redcarpet::Markdown.new(RedcarpetRenderer, :fenced_code_blocks => true, :no_intra_emphasis => true, :tables => true)
      markdown.render(text)
    end

    def self.generate_id(text)
      text.strip.downcase.gsub(/[\s,]+/, '-')
    end

    class RedcarpetRenderer < Redcarpet::Render::HTML
      def header(text, level)
        icons = <<-END
          <i class=\"header-icon icon-plus\"></i>
          <i class=\"header-icon icon-minus hide\"></i>
        END

        "<h#{level} id=\"#{HtmlRenderer.generate_id(text)}\">
          #{icons if level == 3}
          #{text}
        </h#{level}>"
      end

      def block_code(code, language)
        if language
          code = CodeRay.scan(code, language).html(:wrap => nil)
        end

        "<pre>#{code}</pre>"
      end
    end
  end
end
