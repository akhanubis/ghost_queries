#encoding: UTF-8

module GCFinder
  class Color
    class << self
      def get(authorization)
        result = GCFinder.api_client.execute(
            api_method: GCFinder.google_calendar.colors.get,
            authorization: authorization)
        if block_given?
          yield(result.data)
        else
          result.data.to_hash
        end
      end

      def get_event(authorization)
        get(authorization) do |color_data|
          color_data.event.to_hash
        end
      end

      def get_calendar(authorization)
        get(authorization) do |color_data|
          color_data.calendar.to_hash
        end
      end
    end
  end
end