#!/bin/bash
set -e

# bundle

#git clean -xdf -- spec/fixtures/cassettes/*
#(git ls-files spec/fixtures/cassettes/ | xargs sed -i'' -e "s/http:\/\/agent%40zendesk\.com:Testing123%21@support\.localhost\([^\"]*\)/https:\/\/sdavidovitz%2Bqa%40zendesk.com:123456@zendeskapi\.zd-staging\.com\1/g")

#echo 'username: "sdavidovitz+qa@zendesk.com"' > spec/fixtures/credentials.yml
#echo "token: \"$OAUTH_TOKEN\"" >> spec/fixtures/credentials.yml
#echo "url: \"https://zendeskapi.zd-staging.com/api/v2\"" >> spec/fixtures/credentials.yml
#echo "auth: \"$STAGING_AUTH"\" >> spec/fixtures/credentials.yml
bundle exec rake spec:live
