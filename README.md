geminabox-release
=================

This gem is a dependency free option to add a rake inabox:release task that mirrors bundler's rake release task for your
geminabox server.

## How to use

Simply load this gem and and patch with your geminabox URL before requiring bundler/gem_tasks in your Rakefile.

E.g.

```
require 'geminabox-release'
GeminaboxRelease.patch("http://localhost:4000")
require 'bundler/gem_tasks'

```

Then you will get an rake inabox:release task.

The gem (theoretically) supports basic auth like geminabox in the host address. e.g. http://username:password@localhost:4000
It's untested as we didn't need it. Feel free to try it.

The order is important as requiring bunlder/gem_tasks creates the rake tasks and this gem does not modify them after that.

## Safety

To ensure you are not accidently pushing your gem to rubygems there are two distinct safety measures.

1) The rake task has another name. Do not use rake release if you want to push to your geminabox server!

2) The gem is pushed via the HTTP POST file request geminabox expects and not via the gem push interface.

# LICENSE

Copyright (c) 2014 Dennis-Florian Herr @ Experteer GmbH

see {LICENSE}

