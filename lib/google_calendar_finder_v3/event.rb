#encoding: UTF-8

module GCFinder
  class Event
    extend GCFinder::GhostQueries
    MUST_HAVE_FIELDS = 2

    class << self
      def find(authorization, calendar_id, &keep_if_block)
        puts "#{name}: Ejecutando find en #{calendar_id} #{(block_given?)? 'CON' : 'SIN'} bloque"
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
        puts "#{name}: Ejecutando select en #{calendar_id} #{(block_given?)? 'CON' : 'SIN'} bloque"
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
        puts "#{name}: Ejecutando reject en #{calendar_id} #{(block_given?)? 'CON' : 'SIN'} bloque"
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

      def find_hashed(authorization, calendar_id, conditions)
        puts "#{name}: Ejecutando find_hashed en #{calendar_id} con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        find(authorization, calendar_id) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          puts "#{name}: Match!" if found
          found
        end
      end

      def select_hashed(authorization, calendar_id, conditions)
        puts "#{name}: Ejecutando select_hashed en #{calendar_id} con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        select(authorization, calendar_id) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          puts "#{name}: Match!" if found
          found
        end
      end

      def reject_hashed(authorization, calendar_id, conditions)
        puts "#{name}: Ejecutando reject_hashed en #{calendar_id} con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        reject(authorization, calendar_id) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          puts "#{name}: Match!" unless found
          found
        end
      end
    end
  end
end