require "rubygems"
require "geminabox"

Geminabox.rubygems_proxy = true
Geminabox.allow_remote_failure = true 
Geminabox.data = "geminabox-data" # ... or wherever
run Geminabox::Server
