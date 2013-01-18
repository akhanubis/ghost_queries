#encoding: UTF-8

module GCFinder
  class Setting
    class << self
      acts_as_query_ghost :find, :select, :reject

      def find(authorization, &keep_if_block)
        puts "#{name}: Ejecutando find #{(block_given?)? 'con' : 'sin'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        hashed_body = JSON.parse(result.body)
        hashed_body['items'].find(&keep_if_block)
      end

      def select(authorization, &keep_if_block)
        puts "#{name}: Ejecutando select #{(block_given?)? 'con' : 'sin'} bloque"
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
        puts "#{name}: Ejecutando reject #{(block_given?)? 'con' : 'sin'} bloque"
        result = GCFinder.api_client.execute(
          api_method: GCFinder.google_calendar.settings.list,
          authorization: authorization)
        hashed_body = JSON.parse(result.body)
        hashed_body['items'].reject(&keep_if_block)
      end
    end
  end
end