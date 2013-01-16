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
      super(sym, *args, &block) unless ghost_query_method?(sym)

      stripped = sym.to_s.match /^(find|select|reject)_by_(.*)$/
      base_method = "#{stripped[1]}_hashed"
      param_names = stripped[2].split('_and_')

      static_params = args[0..-(param_names.size + 1)]
      param_values = args[-param_names.size..-1]

      args_formatted = static_params + param_values.map{|str| "'#{str}'"}
      puts "#{(respond_to?(:name))? name : self.class}: Método no encontrado: #{sym}(#{args_formatted * ', '})"

      param_values_enum = param_values.each
      conditions = param_names.each_with_object({}) do |param_name, hash|
        hash.merge!(param_name => param_values_enum.next)
      end

      puts "#{(respond_to?(:name))? name : self.class}: Invocando #{base_method}(#{static_params * ', '}, #{conditions})"
      send(base_method, *static_params, conditions, &block)
    end

    def find_hashed(*args)
      conditions = args.last
      puts "#{(respond_to?(:name))? name : self.class}: Ejecutando find_hashed con:"
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
        puts "#{(respond_to?(:name))? name : self.class}: Match!" if found
        found
      end
    end

    def select_hashed(*args)
      conditions = args.last
      puts "#{(respond_to?(:name))? name : self.class}: Ejecutando select_hashed con:"
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
        puts "#{(respond_to?(:name))? name : self.class}: Match!" if found
        found
      end
    end

    def reject_hashed(*args)
      conditions = args.last
      puts "#{(respond_to?(:name))? name : self.class}: Ejecutando reject_hashed con:"
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
        puts "#{(respond_to?(:name))? name : self.class}: Match!" if found
        found
      end
    end
  end
end