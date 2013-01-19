#encoding: UTF-8

require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'

module GhostQueries
  mattr_accessor :log_enabled

  def ghost_queries_debug(debug_message)
    puts "#{(respond_to?(:name))? name : self.class}: #{debug_message}" if GhostQueries.log_enabled
  end

  def strip_query_method(sym)
    sym.to_s.match /^(?<method>#{ghost_queries_methods * '|'})_by_(?<method_suffixes>.*)$/
  end

  def respond_to_missing?(sym, *)
	  !!strip_query_method(sym) || super
	end

	def method_missing(sym, *args, &block)
    ghost_queries_debug "Método no encontrado: #{sym}(#{args * ', '})"
    if stripped = strip_query_method(sym)
      call_hashed_query(stripped, args)
    else
      super
    end
  end

  def call_hashed_query(method_name_matchdata, method_args)
    query_method = "#{method_name_matchdata[:method]}_hashed"
    param_names = method_name_matchdata[:method_suffixes].split('_and_')
    param_values = method_args[-param_names.size..-1]
    #extra parameters not used as conditions for the query but required by the underlying iterator method (find, select, etc)
    #(e.g. Google Calendar authorization token for queries on Google Calendar resources)
    static_params = method_args[0..-(param_names.size + 1)]
    #build the query hash matching each key (param_name) with the value (param_value) we are searching for
    param_values_enum = param_values.each
    conditions = param_names.each_with_object({}) do |param_name, hash|
      hash.merge!(param_name => param_values_enum.next)
    end

    ghost_queries_debug "Invocando #{query_method}(#{[*static_params, conditions] * ', '})"
    #call *_hashed with the extra parameters as is and the conditions hash
    send(query_method, *static_params, conditions)
  end
end

class Class
  def acts_as_query_ghost(*supported_methods)
    include GhostQueries
    define_method(:ghost_queries_methods) { supported_methods.map(&:to_s) }

    supported_methods.each do |method|
      define_method "#{method}_hashed" do |*args|
        conditions = args.last
        ghost_queries_debug "Ejecutando #{method}_hashed con:"
        conditions.each {|k, v| ghost_queries_debug "  #{k}: #{v}"}
        send(method, *args[0..-2]) do |item|
          raise ArgumentError.new("#{item} must respond_to to_hash") unless item.respond_to? :to_hash
          item_attrs = item.to_hash.stringify_keys
          found = true
          conditions.each do |attr, value|
            if item_attrs[attr.to_s] != value
              found = false
              break
            end
          end
          ghost_queries_debug "Match!" if found
          found
        end
      end
    end
  end
end

class Array
  acts_as_query_ghost :find, :select, :reject, :count, :detect, :find_all
end

#for a non trivial example of using acts_as_query_ghost as extend, check github/akhanubis/google_calendar_finder_demo
class MyClass
  attr_accessor :attr1, :attr2, :attr3

  def initialize(attrs = {})
    attrs.each do |name, value|
      send("#{name}=", value)
    end
  end

  @some_instances = [
      new(attr1: 'hola', attr2: 'chau'),
      new(attr1: 'hola', attr2: 'hasta luego'),
      new(attr2: 'chau', attr3: 'nos vemos')
  ]

  def to_hash
    self.instance_variables.each_with_object({}) do |attr, hash|
      hash.merge!(attr[1..-1] => instance_variable_get(attr))
    end
  end

  class << self
    acts_as_query_ghost :select, :count_multiplied

    #class methods of MiClass
    def select(&block)
      #you should retrieve the hashable instances in some way
      @some_instances.select(&block)
    end

    def count_multiplied(multiplier = 1, &block)
      @some_instances.count(&block) * multiplier
    end
  end
end

#[{name: 'Pablo', age: 99}, {name: 'Juan', age: 10}, {name: 'Pablo', age: 10}].find_by_name 'Pablo'
#[{name: 'Pablo', age: 99}, {name: 'Juan', age: 10}, {name: 'Pablo', age: 10}].count_by_name_and_age 'Juan', 10
#[{name: 'Pablo', age: 99}, {name: 'Juan', age: 10}, {name: 'Pablo', age: 10}].reject_hashed age: 10
#MyClass.count_multiplied_by_attr2 5, 'chau'
#MyClass.count_multiplied_by_attr1 'hola'
#MyClass.select_by_attr2 'chau'
#MyClass.select_hashed attr3: 'nos vemos'