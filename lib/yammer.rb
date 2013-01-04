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

    CONFIG_FILE = "config/yammer.tokens"

    def AccessToken.is_token_valid?(token)
      if token.nil?
        false
      else
        token.match(/^[\d\w]+$/) && token.length > 10
      end
    end

    def AccessToken.get_for_username(username)
      Preconditions.check_not_null(username, "Username cannot be null")
      all_tokens[username.strip.to_sym]
    end

    def AccessToken.set_for_username!(username, token)
      Preconditions.check_not_null(username)
      Preconditions.check_not_null(token)
      Preconditions.check_state(Yammer::AccessToken.is_token_valid?(token))
      map = all_tokens
      map[username.strip.to_sym] = token

      s = ""
      map.keys.map(&:to_s).sort.each do |username|
        s << "%s=%s\n" % [username, map[username.to_sym]]
      end
      File.open(CONFIG_FILE, "w") { |out| out << s }
    end

    private
    def AccessToken.all_tokens
      map = {}
      IO.readlines(CONFIG_FILE).each do |line|
        pieces = line.strip.split("=", 2)
        if pieces.length == 2 && AccessToken.is_token_valid?(pieces[1])
          map[pieces[0].strip.to_sym] = pieces[1].strip
        end
      end
      map
    end

  end

  def initialize(username)
    @token = Yammer::AccessToken.get_for_username(username)
    Preconditions.check_not_null(@token, "No token for username[%s]" % [username])
  end

  def message_create!(body)
    Util.with_tempfile do |path|
      command = "curl --silent -X POST --data \"group_id=%s&body=%s\" %s/messages?access_token=%s > %s" %
        [RAILS_DEPLOY_GROUP_ID.to_s, CGI.escape(body), API_URL, CGI.escape(@token), path]
      Util.system_or_fail(command)
    end
  end

end
