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

      #return the first calendar that match with the given values for its attributes.
      def find_hashed(authorization, conditions)
        puts "#{name}: Ejecutando find_hashed con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        find(authorization) do |calendar|
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

      #return an array of the calendars that match the given values for its attributes.
      def select_hashed(authorization, conditions)
        puts "#{name}: Ejecutando select_hashed con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        select(authorization) do |calendar|
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

      #return an array of the calendars that don't match the given values for its attributes.
      def reject_hashed(authorization, conditions)
        puts "#{name}: Ejecutando reject_hashed con:"
        conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
        reject(authorization) do |calendar|
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