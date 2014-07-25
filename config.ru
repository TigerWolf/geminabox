require "rubygems"
require "geminabox"
require 'net-ldap'

Geminabox.rubygems_proxy = true
Geminabox.allow_remote_failure = true
Geminabox.data = "/data/gems"
Geminabox.views = "views"

require 'sinatra'
class Geminabox::Server

  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="LDAP HTTP Auth")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic?
        ldap = Net::LDAP.new(
          host: "ldap.adelaide.edu.au",
          port: 636,
          encryption: :simple_tls
        )
        logged_in = ldap.bind_as(
          base: "dc=adelaide,dc=edu,dc=au",
          filter: Net::LDAP::Filter.eq("uid", @auth.credentials[0]),
          password: @auth.credentials[1]
        )
      end
      logged_in
    end
  end

  before do
    if request.request_method == 'DELETE'
      protected!
    end
    if request.request_method == 'POST'
      if request.path_info == "/upload"
        protected!
      end
    end
  end

  get '/logo.png' do
    send_file File.join('public', 'UoA_logo.png')
  end
end
run Geminabox::Server
