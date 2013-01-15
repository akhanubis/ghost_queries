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
      static_fields_size = (is_a?(Module))? self::MUST_HAVE_FIELDS : self.class::MUST_HAVE_FIELDS
      args_formatted = args[0, static_fields_size]
      args_formatted.concat(args.drop(static_fields_size).map{|str| "'#{str}'"})
      if respond_to? :name
        puts "#{name}: Método no encontrado: #{sym}(#{args_formatted * ', '})"
      else
        puts "#{self.class}: Método no encontrado: #{sym}(#{args_formatted * ', '})"
      end
      super(sym, *args, &block) unless ghost_query_method?(sym)
      stripped = sym.to_s.match /^(find|select|reject)_by_(.*)$/
      base_method = "#{stripped[1]}_hashed"

      static_params = args[0, static_fields_size]
      param_values = args.drop(static_fields_size)
      param_names = stripped[2].split('_and_')
      raise ArgumentError.new("Recibidos #{param_values.size} parámetros para #{param_names.size} atributos parseados") unless param_names.size == param_values.size

      param_values_enum = param_values.each
      conditions = param_names.each_with_object({}) do |param_name, hash|
        hash.merge!(param_name => param_values_enum.next)
      end
      if respond_to? :name
        puts "#{name}: Invocando #{base_method}(#{static_params * ', '}, #{conditions})"
      else
        puts "#{self.class}: Invocando #{base_method}(#{static_params * ', '}, #{conditions})"
      end
      send(base_method, *static_params, conditions, &block)
    end

    def find_hashed(*args)
      conditions = args.last
      if respond_to? :name
        puts "#{name}: Ejecutando find_hashed con:"
      else
        puts "#{self.class}: Ejecutando find_hashed con:"
      end
      conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
      find(*args[0..-2]) do |item|
        raise ArgumentError.new("#{item} must respond_to to_hash") unless item.respond_to? :to_hash
        found = true
        conditions.each do |attr, value|
          if item.to_hash.stringify_keys[attr.to_s] != value
            found = false
            break
          end
        end
        if respond_to? :name
          puts "#{name}: Match!" if found
        else
          puts "#{self.class}: Match!" if found
        end
        found
      end
    end

    def select_hashed(*args)
      conditions = args.last
      if respond_to? :name
        puts "#{name}: Ejecutando select_hashed con:"
      else
        puts "#{self.class}: Ejecutando select_hashed con:"
      end
      conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
      select(*args[0..-2]) do |item|
        raise ArgumentError.new("#{item} must respond_to to_hash") unless item.respond_to? :to_hash
        found = true
        conditions.each do |attr, value|
          if item.to_hash.stringify_keys[attr.to_s] != value
            found = false
            break
          end
        end
        if respond_to? :name
          puts "#{name}: Match!" if found
        else
          puts "#{self.class}: Match!" if found
        end
        found
      end
    end

    def reject_hashed(*args)
      conditions = args.last
      if respond_to? :name
        puts "#{name}: Ejecutando reject_hashed con:"
      else
        puts "#{self.class}: Ejecutando reject_hashed con:"
      end
      conditions.each {|k, v| puts %Q{  #{k}: "#{v}"}}
      reject(*args[0..-2]) do |item|
        raise ArgumentError.new("#{item} must respond_to to_hash") unless item.respond_to? :to_hash
        found = true
        conditions.each do |attr, value|
          if item.to_hash.stringify_keys[attr.to_s] != value
            found = false
            break
          end
        end
        if respond_to? :name
          puts "#{name}: Match!" unless found
        else
          puts "#{self.class}: Match!" unless found
        end
        found
      end
    end
  end
end