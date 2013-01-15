#encoding: UTF-8

module GCFinder
  class Setting
    extend GCFinder::GhostQueries
    MUST_HAVE_FIELDS = 1

    class << self
      def find(authorization, &keep_if_block)
        puts "#{name}: Ejecutando find #{(block_given?)? 'CON' : 'SIN'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        hashed_body = JSON.parse(result.body)
        hashed_body['items'].find(&keep_if_block)
      end

      def select(authorization, &keep_if_block)
        puts "#{name}: Ejecutando select #{(block_given?)? 'CON' : 'SIN'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        hashed_body = JSON.parse(result.body)
        selected_items = if block_given?
                           hashed_body['items'].select(&keep_if_block)
                         else
                           hashed_body['items']
                         end
      end

      def reject(authorization, &keep_if_block)
        puts "#{name}: Ejecutando reject #{(block_given?)? 'CON' : 'SIN'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        hashed_body = JSON.parse(result.body)
        hashed_body['items'].reject(&keep_if_block)
      end
    end
  end
end