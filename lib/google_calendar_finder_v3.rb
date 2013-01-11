require 'google/api_client'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'

module GCFinder
  autoload :GhostRespondTo, 'google_calendar_finder_v3/ghost_queries'
  autoload :GhostQueries, 'google_calendar_finder_v3/ghost_queries'
  autoload :Utils,  'google_calendar_finder_v3/utils'
  autoload :Calendar,  'google_calendar_finder_v3/calendar'
  autoload :CalendarList,  'google_calendar_finder_v3/calendar_list'
  autoload :Acl,  'google_calendar_finder_v3/acl'
  autoload :Color,  'google_calendar_finder_v3/color'
  autoload :Setting,  'google_calendar_finder_v3/setting'

  def self.api_client
    @@api_client ||= (
      client = Google::APIClient.new
      client.authorization.client_id = CLIENT_ID
      client.authorization.client_secret = CLIENT_SECRET
      client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
      p 'SE CREO UN NUEVO CLIENT'
      client
    )
  end

  def self.google_calendar
    @@google_calendar ||= (
      p 'SE CREO UN NUEVO GOOGLE CALENDAR'
      api_client.discovered_api('calendar', 'v3')
    )
  end

  def self.dup_authorization
    auth = api_client.authorization.dup
    auth.redirect_uri = REDIRECT_URI
    auth
  end
end