#!/bin/bash
set -e

# bundle

#git clean -xdf -- spec/fixtures/cassettes/*
#(git ls-files spec/fixtures/cassettes/ | xargs sed -i'' -e "s/http:\/\/agent%40zendesk\.com:Testing123%21@support\.localhost\([^\"]*\)/https:\/\/sdavidovitz%2Bqa%40zendesk.com:123456@zendeskapi\.zd-staging\.com\1/g")
# https://sdavidovitz%2Bqa%40zendesk.com:123456@zendeskapi.zd-staging.com/api/v2/automations/26633472.json
# git ls-files spec/fixtures/cassettes/ | xargs sed -i '.bak' -e "s/\(https:\/\/sdavidovitz%2Bqa%40zendesk\.com:123456@[^\.]*\)\.json/\1/g"
#(git ls-files spec/fixtures/cassettes/ | xargs sed -i '.bak' -e "s/\(https:\/\/sdavidovitz[^\"]*\)\.json/\1/g" spec/fixtures/cassettes/ZendeskAPI_Automation/deletion/should_be_destroyable.json) && \
#  git clean -xfd -- spec/fixtures/cassettes/


#echo 'username: "sdavidovitz+qa@zendesk.com"' > spec/fixtures/credentials.yml
#echo "token: \"$OAUTH_TOKEN\"" >> spec/fixtures/credentials.yml
#echo "url: \"https://zendeskapi.zd-staging.com/api/v2\"" >> spec/fixtures/credentials.yml
#echo "auth: \"$STAGING_AUTH"\" >> spec/fixtures/credentials.yml
bundle exec rake spec:live
