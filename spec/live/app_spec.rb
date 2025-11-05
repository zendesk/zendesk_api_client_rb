require "core/spec_helper"

describe ZendeskAPI::App do
  it "should work" do
    upload = VCR.use_cassette("app_upload_create") do
      ZendeskAPI::App::Upload.new(client, id: "spec/fixtures/sample_app.zip").tap(&:save!)
    end

    attributes = {upload_id: upload.id, name: "My App", short_description: "Testing"}

    app = ZendeskAPI::App.new(client, attributes)

    VCR.use_cassette("app_create") { app.save! }

    body = check_job(app)

    app.id = body["app_id"]
    app.author_name = "Mr. Sprinkles"
    app.author_email = "sprinkle@example.com"

    VCR.use_cassette("app_save") { app.save! }

    expect(app.author_name).to eq("Mr. Sprinkles")

    VCR.use_cassette("app_find") { client.apps.find!(id: app.id) }
    VCR.use_cassette("app_destroy") { app.destroy! }
  end

  it "should be able to handle the simplest creation api call" do
    VCR.use_cassette("app_simple_create") do
      app = ZendeskAPI::App.create!(client, {name: "Testing App Creation", upload: "spec/fixtures/sample_app.zip"})

      body = check_job(app)

      app.id = body["app_id"]
      VCR.use_cassette("app_destroy") { app.destroy! }
    end
  end

  def check_job(app)
    body = {}

    VCR.use_cassette("app_create_job_status") do
      until %w[failed completed].include?(body["status"])
        response = client.connection.get(app.response.headers["Location"])
        body = response.body

        sleep(3)
      end
    end

    if body["status"] == "failed"
      fail "Could not create app: #{body.inspect}"
    end

    body
  end
end
