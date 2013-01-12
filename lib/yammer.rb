#!/usr/bin/env ruby

require 'cgi'
require 'tempfile'

class Yammer

  APP_CLIENT_ID = 'Kaz4fktu6qpGNh9mmqZyiA'

  URL = "https://www.yammer.com"
  API_URL = "#{URL}/api/v1"
  GET_TOKEN_URL = "%s/dialog/oauth?client_id=%s&redirect_uri=%s&response_type=token" % [URL, APP_CLIENT_ID, 'http://www.gilt.com']

  RAILS_DEPLOY_GROUP_ID = 1142230

  module AccessToken

    TOKEN_FILE_PATTERN = ".yammer_token.%s"

    def AccessToken.is_token_valid?(token)
      if token.nil?
        false
      else
        token.match(/^[\d\w]+$/) && token.length > 10
      end
    end

    def AccessToken.get_for_username(username)
      Preconditions.check_not_null(username, "Username cannot be null")
      file = AccessToken.get_file(username)
      if File.exists?(file)
        token = IO.read(file).strip
        if Yammer::AccessToken.is_token_valid?(token)
          return token
        end
      end
      nil
    end

    def AccessToken.set_for_username!(username, token)
      Preconditions.check_not_null(username)
      Preconditions.check_not_null(token)
      Preconditions.check_state(Yammer::AccessToken.is_token_valid?(token))
      File.open(get_file(username), "w") { |out| out << token }
    end

    private
    def AccessToken.get_file(username)
      Preconditions.check_not_null(username, "Username cannot be null")
      TOKEN_FILE_PATTERN % [username]
    end

  end

  def initialize(username)
    @token = Yammer::AccessToken.get_for_username(username)
    Preconditions.check_not_null(@token, "No token for username[%s] - run:\n  rake yammer_configure" % [username])
  end

  def message_create!(body, opts={})
    topics = opts.delete(:topics) || []
    if opts.size > 0
      raise "Invalid opts: #{opts.inspect}"
    end

    Util.with_tempfile do |path|
      data = "group_id=%s&body=%s" % [RAILS_DEPLOY_GROUP_ID.to_s, CGI.escape(body)]
      topics.each_with_index do |t, i|
        data << "&topic%s=%s" % [i+1, CGI.escape(t)]
      end
      command = "curl --silent -X POST --data \"%s\" %s/messages?access_token=%s > %s" %
        [data, API_URL, CGI.escape(@token), path]
      Util.system_or_fail(command)
    end
  end

end
