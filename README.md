geminabox-release
=================
[![Gem Version](https://badge.fury.io/rb/geminabox-release.png)](http://badge.fury.io/rb/geminabox-release)

This gem is a dependency free option to add a rake inabox:release task to bundler gem_tasks for releasing a new gem to
 your geminabox server. 
 
 
You no longer need to require "bundler/gem_tasks". The gem does it for you. Make sure you do not require bundler/gem_tasks
anywhere before geminabox-release gets required.

## How to use

Simply load this gem and patch with your geminabox URL in your Rakefile. 

E.g.

```ruby
require 'geminabox-release'
GeminaboxRelease.patch(:host => "http://localhost:4000")

```

or use your geminabox config file (YAML file with key :host and host url as value in ~/.gem/geminabox)

```ruby
require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true)

```

Then you will get a rake inabox:release task.

The gem (theoretically) supports basic auth like geminabox in the host address. e.g. http://username:password@localhost:4000
It's untested as we didn't need it. Feel free to try it.


### Additional tasks

The gem additionally provides tasks for build & push without all the overhead release produces (like git tag and git push):

```Shell
$> rake inabox:push          # just builds gem and pushes to geminabox server
$> rake inabox:forcepush     # builds gem and pushes to geminabox server overwriting existing same version

```

## Safety

To ensure you are not accidently pushing your gem to rubygems there are two distinct safety measures.

1) The rake task has another name. Do not use rake release if you want to push to your geminabox server!

2) The gem is pushed via the HTTP POST file request geminabox expects and not via the gem push interface.

### Troubleshooting

If the rake tasks do not show check if you required "bundler/gem_tasks" anywhere before requiring geminabox-release.

# LICENSE

Copyright (c) 2014 Dennis-Florian Herr @ Experteer GmbH

see [LICENSE](LICENSE)

