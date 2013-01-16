#encoding: UTF-8

module GCFinder
  class Event
    extend GCFinder::GhostQueries

    class << self
      def find(authorization, calendar_id, &keep_if_block)
        puts "#{name}: Ejecutando find en #{calendar_id} #{(block_given?)? 'con' : 'sin'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.events.list,
          parameters: {'calendarId' => calendar_id},
          authorization: authorization)
        while true
          hashed_body = JSON.parse(result.body)
          match = hashed_body['items'].find(&keep_if_block)
          return match if match
          return nil if !(page_token = result.data.next_page_token)
          result = api_client.execute(
            api_method: GCFinder.google_calendar.events.list,
            parameters: {'calendarId' => calendar_id, 'pageToken' => page_token},
            authorization: authorization)
        end
      end

      def select(authorization, calendar_id, &keep_if_block)
        puts "#{name}: Ejecutando select en #{calendar_id} #{(block_given?)? 'con' : 'sin'} bloque"
        matches = []
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.events.list,
          parameters: {'calendarId' => calendar_id},
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
            api_method: GCFinder.google_calendar.events.list,
            parameters: {'calendarId' => calendar_id, 'pageToken' => page_token},
            authorization: authorization)
        end
      end

      #return an array of the calendars for which keep_if_block returns false
      def reject(authorization, calendar_id, &keep_if_block)
        puts "#{name}: Ejecutando reject en #{calendar_id} #{(block_given?)? 'con' : 'sin'} bloque"
        matches = []
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.events.list,
          parameters: {'calendarId' => calendar_id},
          authorization: authorization)
        while true
          hashed_body = JSON.parse(result.body)
          matches.concat(hashed_body['items'].reject(&keep_if_block))
          return matches.compact if !(page_token = result.data.next_page_token)
          result = api_client.execute(
            api_method: GCFinder.google_calendar.events.list,
            parameters: {'calendarId' => calendar_id, 'pageToken' => page_token},
            authorization: authorization)
        end
      end

      alias list select
    end
  end
end