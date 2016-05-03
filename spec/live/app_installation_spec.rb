require 'core/spec_helper'

describe ZendeskAPI::AppInstallation do
  it "should work" do
    upload = VCR.use_cassette("app_installations_upload_create") do
      ZendeskAPI::App::Upload.new(client, :id => "spec/fixtures/sample_app.zip").tap(&:save!)
    end

    attributes = { :upload_id => upload.id, :name => "My App", :short_description => "Testing" }

    app = ZendeskAPI::App.new(client, attributes)

    VCR.use_cassette("app_installations_create") { app.save! }

    body = {}

    VCR.use_cassette("app_installations_create_job_status") do
      until %w{failed completed}.include?(body["status"])
        response = client.connection.get(app.response.headers["Location"])
        body = response.body

        sleep(3)
      end
    end

    if body["status"] == "failed"
      fail "Could not create app: #{body.inspect}"
    end

    app.id = body["app_id"]

    attributes = {
      :app_id => app.id,
      :settings => {
        :name => "My App"
      }
    }

    install = ZendeskAPI::AppInstallation.new(client, attributes)

    VCR.use_cassette("app_install_create") { install.save! }

    installations = client.app.installations
    VCR.use_cassette("app_install_fetch") { installations.fetch! }
    VCR.use_cassette("app_install_find") { client.app.installations.find!(:id => install.id) }

    expect(installations).to include(install)

    install.settings.name = "My New Name"
    VCR.use_cassette("app_install_update") { install.save! }

    expect(install.settings.title).to eq("My New Name")

    VCR.use_cassette("app_install_destroy") { install.destroy! }

    VCR.use_cassette("app_installations_destroy") { app.destroy! }
  end
end
