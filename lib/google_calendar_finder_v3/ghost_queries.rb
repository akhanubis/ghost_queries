module GCFinder
  module GhostRespondTo
    def respond_to?(sym)
      ghost_query_method?(sym) || super(sym)
    end

    private
    def ghost_query_method?(sym)
      case sym
        when /^(find|select|reject)_by/ then true
        else
          false
      end
    end
  end

  module GhostQueries
    include GCFinder::GhostRespondTo

    def method_missing(sym, *args, &block)
      super(sym, *args, &block) unless ghost_query_method?(sym)
      stripped = sym.to_s.match /^(find|select|reject)_by_(.*)$/
      base_method = "#{stripped[1]}_hashed"

      authorization = args[0]
      param_names = stripped[2].split('_and_')
      param_values = args[1..-1]
      raise ArgumentError.new("wrong number of arguments(#{param_values.size} for #{param_names.size})") unless param_names.size == param_values.size

      param_values_enum = param_values.each
      conditions = param_names.each_with_object({}) do |param_name, hash|
        hash.merge!(param_name => param_values_enum.next)
      end

      send(base_method, authorization, conditions, &block)
    end
  end
end