# Zendesk API Client

## API version support

This client **only** supports Zendesk's v2 API.  Please see our [API documentation](http://developer.zendesk.com) for more information.

## Documentation

Please check out the [wiki](https://github.com/zendesk/zendesk_api_client_rb/wiki), [class documentation](https://zendesk-api.herokuapp.com/doc/index.html), and [issues](https://github.com/zendesk/zendesk_api_client_rb/issues) before reporting a bug or asking for help.

## Important Notices

* Version 0.0.5 brings with it a change to the top-level namespace. All references to Zendesk should now use ZendeskAPI.
* Version 0.3.0 changed the license from MIT to Apache Version 2.
* Version 0.3.2 introduced a regression when side-loading roles on users. This was fixed in 0.3.4.

## Installation

The Zendesk API client can be installed using Rubygems or Bundler.

### Rubygems

```sh
gem install zendesk_api
```

### Bundler

Add it to your Gemfile

    gem "zendesk_api"

and follow normal [Bundler](http://gembundler.com/) installation and execution procedures.

## Note on Patches/Pull Requests
1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version
   unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have
   your own version, that is fine but bump version in a commit by itself I can
   ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Supported Ruby Versions

Tested with Ruby 1.8.7 and 1.9.3
[![Build Status](https://secure.travis-ci.org/zendesk/zendesk_api_client_rb.png?branch=master)](http://travis-ci.org/zendesk/zendesk_api_client_rb)

## Copyright and license

Copyright 2013 Zendesk

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
