geminabox-release
=================

This gem is a dependency free option to modify your bundler rake release task to work with your geminabox server.

## How to use

Simply load this gem and and patch with your geminabox URL before requiring bundler/gem_tasks in your Rakefile.

E.g.

```
require 'geminabox-release'
GeminaboxRelease.patch("http://localhost:4000")
require 'bundler/gem_tasks'

```

Then your bundler rake release will be overwritten with rake release:inabox to your specified host.

The gem (theoretically) supports basic auth like geminabox in the host address. e.g. http://username:password@localhost:4000
It's untested as we didn't need it. Feel free to try it.

The order is important as requiring bunlder/gem_tasks creates the rake tasks and this gem does not modify them after that.


# LICENSE

Copyright (c) 2014 Dennis-Florian Herr @ Experteer GmbH

see {LICENSE}

