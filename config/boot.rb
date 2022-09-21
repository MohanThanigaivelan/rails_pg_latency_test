require 'toxiproxy'
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

Toxiproxy.host = "http://host.docker.internal:8474"
@proxies = Toxiproxy.populate([
  {
     name: "postgres",
     listen: "toxiproxy:22001",
     upstream: "db:5432",
  }
 ])
