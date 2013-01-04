#!/usr/bin/env ruby

require 'cgi'
require 'tempfile'

class Yammer

  URL = "https://www.yammer.com/api/v1"
  RAILS_DEPLOY_GROUP_ID = 1142230

  # To get an access token:
  # 1. In a browser, goto
  #    https://www.yammer.com/dialog/oauth?client_id=Kaz4fktu6qpGNh9mmqZyiA&redirect_uri=http://www.gilt.com&response_type=token
  # 2. Copy the access_token  from the URL
  ACCESS_TOKENS = {
    :mbryzek => 'GiCwrLXf613oifO6kSKrXw'
  }

  def initialize(username)
    Preconditions.check_not_null(username)
    @token = ACCESS_TOKENS[username.to_sym]
    Preconditions.check_not_null(@token, "No token for username[%s]" % [username])
  end

  def message_create!(body)
    tmp = Tempfile.new('util-rails-deploy-yammer')
    begin
      command = "curl --silent -X POST --data \"group_id=%s&body=%s\" %s/messages?access_token=%s > %s" %
        [RAILS_DEPLOY_GROUP_ID.to_s, CGI.escape(body), URL, CGI.escape(@token), tmp.path]
      Util.system_or_fail(command)
    ensure
      if File.exists?(tmp.path)
        File.delete(tmp.path)
      end
    end
  end

end
