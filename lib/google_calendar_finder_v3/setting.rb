#encoding: UTF-8

module GCFinder
  class Setting
    class << self
      def get(authorization, setting)
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.get,
          parameters: {'setting' => setting},
          authorization: authorization)
        result.data.value
      end

      def list(authorization)
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        result.data.items
      end
    end
  end
end