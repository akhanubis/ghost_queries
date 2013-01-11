module GCFinder
  class CalendarList
    extend GCFinder::GhostQueries

    class << self
      #return the first calendar for which keep_if_block returns true or nil.
      def find(authorization, &keep_if_block)
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
        find(authorization) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          found
        end
      end

      #return an array of the calendars that match the given values for its attributes.
      def select_hashed(authorization, conditions)
        select(authorization) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          found
        end
      end

      #return an array of the calendars that don't match the given values for its attributes.
      def reject_hashed(authorization, conditions)
        reject(authorization) do |calendar|
          found = true
          conditions.each do |attr, value|
            if calendar[attr.to_s] != value
              found = false
              break
            end
          end
          found
        end
      end

      #return the first calendar with summary equal to calendar_summary.
      def find_by_summary(authorization, calendar_summary)
        find_hashed(authorization, summary: calendar_summary)
      end

      #return an array of the calendars with summary equal to calendar_summary.
      def select_by_summary(authorization, calendar_summary)
        select_hashed(authorization, summary: calendar_summary)
      end

      #return an array of the calendars with summary equal to calendar_summary.
      def reject_by_summary(authorization, calendar_summary)
        reject_hashed(authorization, summary: calendar_summary)
      end

      alias find_by_name find_by_summary
      alias select_by_name select_by_summary
      alias reject_by_name reject_by_summary
    end
  end
end