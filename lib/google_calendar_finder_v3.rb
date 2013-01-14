#encoding: UTF-8

require 'google/api_client'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'

if Rails.env.production?
  require 'google_calendar_finder_v3/ghost_queries'
  require 'google_calendar_finder_v3/utils'
  require 'google_calendar_finder_v3/calendar_list'
  require 'google_calendar_finder_v3/calendar'
  require 'google_calendar_finder_v3/acl'
  require 'google_calendar_finder_v3/color'
  require 'google_calendar_finder_v3/setting'
  require 'google_calendar_finder_v3/event'
end

module GCFinder
  if Rails.env.development?
    autoload :GhostRespondTo, 'google_calendar_finder_v3/ghost_queries'
    autoload :GhostQueries, 'google_calendar_finder_v3/ghost_queries'
    autoload :Utils,  'google_calendar_finder_v3/utils'
    autoload :Calendar,  'google_calendar_finder_v3/calendar'
    autoload :CalendarList,  'google_calendar_finder_v3/calendar_list'
    autoload :Acl,  'google_calendar_finder_v3/acl'
    autoload :Color,  'google_calendar_finder_v3/color'
    autoload :Setting,  'google_calendar_finder_v3/setting'
    autoload :Event, 'google_calendar_finder_v3/event'
  end
  def self.api_client
    @@api_client ||= (
      client = Google::APIClient.new(application_name: 'una app', application_version: '0.0.1')
      @@google_calendar = client.discovered_api('calendar', 'v3')
      client.authorization.client_id = CLIENT_ID
      client.authorization.client_secret = CLIENT_SECRET
      client.authorization.redirect_uri = REDIRECT_URI
      client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
      #p "SE CREO UN NUEVO CLIENT #{client}"
      #p client.authorization
      client
    )
  end

  def self.google_calendar
    @@google_calendar ||= (
      #p 'SE CREO UN NUEVO GOOGLE CALENDAR'
      api_client.discovered_api('calendar', 'v3')
    )
  end

  def self.dup_authorization
    auth = api_client.authorization.dup
    auth
  end

  def self.authorization_url
    api_client.authorization.authorization_uri.to_s
  end
end