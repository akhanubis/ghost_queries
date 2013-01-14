#encoding: UTF-8

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
      static_fields_size = self::MUST_HAVE_FIELDS
      args_formatted = args[0..static_fields_size - 1]
      args_formatted.concat(args[static_fields_size..-1].map{|str| "'#{str}'"})
      puts "#{name}: Método no encontrado: #{sym}(#{args_formatted * ', '})"
      super(sym, *args, &block) unless ghost_query_method?(sym)
      stripped = sym.to_s.match /^(find|select|reject)_by_(.*)$/
      base_method = "#{stripped[1]}_hashed"

      static_params = args[0..static_fields_size - 1]
      param_values = args[static_fields_size..-1]
      param_names = stripped[2].split('_and_')
      raise ArgumentError.new("#{name}: Recibidos #{param_values.size} parámetros para #{param_names.size} atributos parseados") unless param_names.size == param_values.size

      param_values_enum = param_values.each
      conditions = param_names.each_with_object({}) do |param_name, hash|
        hash.merge!(param_name => param_values_enum.next)
      end
      puts "#{name}: Invocando #{base_method}(#{static_params * ', '}, #{conditions})"
      send(base_method, *static_params, conditions, &block)
    end
  end
end