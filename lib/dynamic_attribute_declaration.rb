require "dynamic_attribute_declaration/version"

module DynamicAttributeDeclaration
  extend ActiveSupport::Concern

  included do
    class_attribute :_dynamic_attrs
    class_attribute :_dynamic_attr_state_if
    self._dynamic_attrs = {}
    self._dynamic_attr_state_if = Proc.new { false }
  end

  def values_for attr_name
    if _dynamic_attrs.key?(attr_name)
      rtn = nil
      _dynamic_attrs[attr_name].each do |attr|
        if attr.key?(:values)
          rtn = attr[:values]
        end
      end
    end
    rtn
  end

  module ClassMethods

    def inherited(base) #:nodoc:
      dup = _dynamic_attrs.dup
      base._dynamic_attrs = dup.each { |k, v| dup[k] = v.dup }
      base._dynamic_attr_state_if = nil
      super
    end

    def clear_dynamic_attrs!
      self._dynamic_attrs = {}
      self._dynamic_attr_state_if = nil
    end

    def define_attr_state_if proc
      throw "define_attr_state_if should be a proc" unless proc.class == Proc
      self._dynamic_attr_state_if = proc
    end

    def define_attrs args
      add_dynamic_attrs args
      build_validations_from_dynamic_attrs args
    end

    def attrs_on_for attr_name
      attr = _dynamic_attrs[attr_name]
      rtn = {}
      attr.each do |a|
        if a.key? :on
          obj = a[:on]
          obj.each do |key, value|
            if rtn.key? key
              rtn[key].push(value).flatten!
            else
              rtn[key] = value
            end
          end
        end
      end
      rtn
    end

    def attrs_for state=nil, device=nil
      if state && state.to_sym != :all
        state = state.to_sym
        device = device ? device.to_sym : nil
        devices = [:all, device].compact.uniq

        _dynamic_attrs.select do |attr_name, definitions|
          on_attrs = attrs_on_for(attr_name)
          if on_attrs
            comparer = (devices & on_attrs.keys).map { |k| on_attrs[k] }.flatten.uniq
          end
          comparer.map(&:to_sym).include? state.to_sym
        end
      else
        _dynamic_attrs
      end
    end

    def attrs_names_for state=nil, device=nil
      attrs_for(state, device).map(&:first)
    end

    def build_validations_from_dynamic_attrs attrs
      # throw "No validation state if defined" unless _rdynamic_attr_state_if
      attrs.each do |attr|
        key, value = *attr.flatten
        if value.key?(:validates) && !value[:validates].empty?
          opts = value[:validates].deep_symbolize_keys

          # Check if validation should only be used in specific state
          if value.key?(:on) && _dynamic_attr_state_if && _dynamic_attr_state_if.class == Proc
            validates_on = value[:on]
            # If validates contains if statement, wrap that statement in state check
            if opts.key?(:if)
              original_if = opts.delete(:if)
              opts.merge! if: ->(model) { model.instance_exec(validates_on, &_dynamic_attr_state_if) && model.instance_eval(&original_if) }
            else
              opts.merge! if: ->(model) { model.instance_exec(validates_on, &_dynamic_attr_state_if) }
            end
          end

          validates key.to_sym, opts
        end
      end
    end

    def add_dynamic_attrs attrs
      attrs.each do |attr|
        key, value = *attr.flatten
        if self._dynamic_attrs.keys.include? key
          self._dynamic_attrs[key].push process_attr(value)
        else
          self._dynamic_attrs[key] = [process_attr(value)]
        end
      end
    end

    def process_attr attr
      rtn = {}
      attr.each do |key, value|
        if key == :on
          case value
          when Symbol
            new_value = { all: [value] }
          when Array
            new_value = { all: value }
          when Hash
            new_value = {}
            value.each { |k,v| new_value[k] = *v }
          else
            throw "Process attr #{value} cannot be of class #{value.class}"
          end
        else
          new_value = value
        end
        rtn[key] = new_value
      end
      rtn
    end
  end
end

ActiveRecord::Base.send(:include, DynamicAttributeDeclaration)