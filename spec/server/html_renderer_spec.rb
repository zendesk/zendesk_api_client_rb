require 'server/spec_helper'

describe ZendeskAPI::Server::HtmlRenderer do
  context "header" do
    subject { described_class.render(markdown) }

    before(:each) do
      described_class.instance_variable_set(:@markdown, nil)
    end

    context "h2" do
      let(:markdown) { "## Hello" }
      let(:id) { described_class.generate_id("Hello") }

      it "should add icons" do
        subject.should =~ /icon-plus/
        subject.should =~ /icon-minus/
      end

      it "should generate an id" do
        subject.should =~ /h2 id="#{id}"/
      end

      it "should add the id to the headers" do
        subject # Render

        described_class.markdown.renderer.headers.should include id
      end
    end

    context "h3" do
      let(:markdown) { "### Hello" }
      let(:id) { described_class.generate_id("Hello") }

      it "should add icons" do
        subject.should =~ /icon-plus/
        subject.should =~ /icon-minus/
      end

      it "should generate an id" do
        subject.should =~ /h3 id="#{described_class.generate_id(id)}"/
      end

      it "should add the id to the headers" do
        subject # Render

        described_class.markdown.renderer.headers.should include id
      end
    end

    context "h1" do
      let(:markdown) { "# Hello" }
      let(:id) { described_class.generate_id("Hello") }

      it "should not add icons" do
        subject.should_not =~ /icon-plus/
        subject.should_not =~ /icon-minus/
      end

      it "should generate an id" do
        subject.should =~ /h1 id="#{described_class.generate_id(id)}"/
      end

      it "should not add the id to the headers" do
        subject # Render

        described_class.markdown.renderer.headers.should_not include id
      end
    end
  end

  context "code" do
    subject { described_class.render(markdown) }

    context "curl" do
      let(:markdown) do
        <<-END
```bash
curl -v -u someone@something.com https://{subdomain}.zendesk.com/api/v2/my_path.json?id={blah} \
  -d '{"hello": {"goodbye": "see you later"}}' -X PUT
```
        END
      end

      it "should have a button" do
        subject.should =~ %r{<button.*</button>}m
      end

      it "should have a pre" do
        subject.should =~ %r{<pre (.*)>curl .*</pre>}m
      end

      context "pre modifiers" do
        let(:modifiers) do
          subject =~ %r{<pre (.*)>curl .*</pre>}m && $1
        end

        it "should have a class" do
          modifiers.should include "class='example'"
        end

        it "should have a data-url" do
          modifiers.should include "data-url='https://{subdomain}.zendesk.com/api/v2/my_path.json?id={blah}'"
        end

        it "should have a data-json" do
          modifiers.should include "data-json='{\"hello\": {\"goodbye\": \"see you later\"}}'"
        end

        it "should have a data-method" do
          modifiers.should include "data-method='PUT'"
        end
      end
    end

    context "other" do
      let(:markdown) do
        <<-END
```json
{ "hello": "goodbye" }
```
        END
      end

      it "should be wrapped in a pre" do
        subject.should =~ %r{^<pre>.*</pre>$}m
      end
    end
  end
end
