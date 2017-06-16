geminabox-release
=================

This is for all users of a geminabox-server who do use bundler and rake, but do not want to install geminabox and all it's
dependencies locally just to have a gem push command.

[![Gem Version](https://badge.fury.io/rb/geminabox-release.png)](http://badge.fury.io/rb/geminabox-release)

If you use bundler, this gem is a dependency free option to add a rake inabox:release task to bundler gem_tasks for releasing a new gem to
 your geminabox server instead of rubygems.
 
It only uses the ruby default libaries uri, net/http and the bundler gem.
 
 
You must no longer require "bundler/gem_tasks" as geminabox-release requires a modified version for you which supports all other functionality!

## How to use

Simply load this gem and patch with your geminabox URL in your Rakefile:

```ruby
require 'geminabox-release'
GeminaboxRelease.patch(:host => "http://localhost:4000")
```

Then you will get a rake `inabox:release` task.

If your server requires basic authentication for the deployment, you can specify `:username` and `:password` as well.

For reasons of compatibility, you can still specify the credentials in the `:host` option (e.g. `http://username:password@localhost:4000`), in which case
they take precedence over the other parameters.

### Global Defaults

You can store global defaults in `~/.gem/geminabox`, for instance:
```yaml
:host: "http://localhost:4000"
:username: "peter.pan"
:password: "secret"
```
Apply them by passing the `:use_config` flag:
```ruby
require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true)

```

If an attribute is present in the global configuration, and also passed to the `GeminaboxRelease.patch` call, the latter takes precedence.

### SSL

If your geminabox server is using SSL/TLS, but you have an untrusted certificate, you can use the option `ssl_dont_verify`.

E.g.

```ruby
require 'geminabox-release'
GeminaboxRelease.patch(:host => "https://localhost:4000", :ssl_dont_verify => true)
```

However, that is _NOT_ recommended.

### Bundler's `release` Task

If you wish to remove the bundler/gem_tasks rake release task, you can by adding `:remove_release` to the patch options:

```ruby
GeminaboxRelease.patch(:remove_release => true)

```

**Ensure you do not _require "bundler/gem_tasks"_ in your rakefile anymore!**


### Additional tasks

The gem additionally provides tasks for build & push without all the overhead release produces (like git tag and git push):

```Shell
$> rake inabox:push          # just builds gem and pushes to geminabox server
$> rake inabox:forcepush     # builds gem and pushes to geminabox server overwriting existing same version

```

## Safety

To ensure you are not accidentally pushing your gem to rubygems there are two distinct safety measures.

1) The rake task has another name. Do not use rake release if you want to push to your geminabox server!

2) The gem is pushed via the HTTP POST file request geminabox expects and not via the gem push interface.

3) Optionally you can even fully remove the rake release task, if you wish to. (see above)

### Troubleshooting

If the rake tasks do not show make sure you did not require "bundler/gem_tasks" anywhere (espacially before requiring geminabox-release).

## Contributors

[Jens Hilligsøe](https://github.com/hilli)

[Frank Schoenheit](https://github.com/frank-schoenheit-red6es)


# LICENSE

Copyright (c) 2014 Dennis-Florian Herr @ Experteer GmbH

see [LICENSE](LICENSE)

