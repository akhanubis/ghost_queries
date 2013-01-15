#encoding: UTF-8

module GCFinder
  class Calendar
    extend GCFinder::GhostRespondTo

    class << self
      delegate :find, :select, :reject, :list, to: GCFinder::CalendarList
      delegate :find_hashed, :select_hashed, :reject_hashed, to: GCFinder::CalendarList

      def method_missing(sym, *args, &block)
        args_formatted = [args.first]
        args_formatted.concat(args[1..-1].map{|str| "'#{str}'"})
        puts "#{name}: Método no encontrado: #{sym}(#{args_formatted * ', '})"
        super(sym, *args, &block) unless ghost_query_method?(sym)
        #proxy the call to CalendarList if it is a query method
        puts "#{name}: Delegando a CalendarList"
        GCFinder::CalendarList.send(sym, *args, &block)
      end
    end
  end
end 