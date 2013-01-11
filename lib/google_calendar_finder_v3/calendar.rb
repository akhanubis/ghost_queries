module GCFinder
  class Calendar
    extend GCFinder::GhostRespondTo

    class << self
      delegate :find, :select, :reject, :list, to: GCFinder::CalendarList
      delegate :find_hashed, :select_hashed, :reject_hashed, to: GCFinder::CalendarList

      #create a calendar on the client's google calendar.
      def create!(authorization, calendar_metadata)
        calendar_metadata.stringify_keys!
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.calendars.insert,
          body: JSON.dump(calendar_metadata),
          headers: {'Content-Type' => 'application/json'},
          authorization: authorization)
        JSON.parse(result.body)
      end

      #find a calendar by its metadata or create a new one if it doesn't exist.
      def find_or_create!(authorization, calendar_metadata)
        if (calendar = find_hashed(authorization, calendar_metadata))
          p 'lo encontreeeee'
          calendar
        else
          p 'no esta, vamos a crearlo'
          create!(authorization, calendar_metadata)
        end
      end

      def method_missing(sym, *args, &block)
        super(sym, *args, &block) unless ghost_query_method?(sym)
        #proxy the call to CalendarList if it is a query method
        GCFinder::CalendarList.send(sym, *args, &block)
      end
    end
  end
end 