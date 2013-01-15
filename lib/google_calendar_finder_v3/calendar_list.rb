#encoding: UTF-8

module GCFinder
  class CalendarList
    extend GCFinder::GhostQueries
    MUST_HAVE_FIELDS = 1

    class << self
      #return the first calendar for which keep_if_block returns true or nil.
      def find(authorization, &keep_if_block)
        puts "#{name}: Ejecutando find #{(block_given?)? 'CON' : 'SIN'} bloque"
        result = GCFinder.api_client.execute(
            api_method: GCFinder.google_calendar.calendar_list.list,
            authorization: authorization)
        while true
          hashed_body = JSON.parse(result.body)
          match = hashed_body['items'].find(&keep_if_block)
          return match if match
          return nil if !(page_token = result.data.next_page_token)
          result = api_client.execute(
              api_method: GCFinder.google_calendar.calendar_list.list,
              parameters: {'pageToken' => page_token},
              authorization: authorization)
        end
      end

      #return an array of the calendars for which keep_if_block returns true.
      def select(authorization, &keep_if_block)
        puts "#{name}: Ejecutando select #{(block_given?)? 'CON' : 'SIN'} bloque"
        matches = []
        result = GCFinder.api_client.execute(
            api_method: GCFinder.google_calendar.calendar_list.list,
            authorization: authorization)
        while true
          hashed_body = JSON.parse(result.body)
          selected_items = if block_given?
                             hashed_body['items'].select(&keep_if_block)
                           else
                             hashed_body['items']
                           end
          matches.concat(selected_items)
          return matches.compact if !(page_token = result.data.next_page_token)
          result = api_client.execute(
              api_method: GCFinder.google_calendar.calendar_list.list,
              parameters: {'pageToken' => page_token},
              authorization: authorization)
        end
      end

      #return an array of the calendars for which keep_if_block returns false
      def reject(authorization, &keep_if_block)
        puts "#{name}: Ejecutando reject #{(block_given?)? 'CON' : 'SIN'} bloque"
        matches = []
        result = GCFinder.api_client.execute(
            api_method: GCFinder.google_calendar.calendar_list.list,
            authorization: authorization)
        while true
          hashed_body = JSON.parse(result.body)
          matches.concat(hashed_body['items'].reject(&keep_if_block))
          return matches.compact if !(page_token = result.data.next_page_token)
          result = api_client.execute(
              api_method: GCFinder.google_calendar.calendar_list.list,
              parameters: {'pageToken' => page_token},
              authorization: authorization)
        end
      end

      #return all the calendars.
      alias list select
    end
  end
end