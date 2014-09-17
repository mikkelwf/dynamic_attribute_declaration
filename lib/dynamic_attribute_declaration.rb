require "dynamic_attribute_declaration/version"

module DynamicAttributeDeclaration
  extend ActiveSupport::Concern

  included do
    class_attribute :_dynamic_attrs
    class_attribute :_dynamic_attr_state_if
    self._dynamic_attrs = HashWithIndifferentAccess.new
    self._dynamic_attr_state_if = Proc.new { false }
  end

  def values_for attr_name
    _dynamic_attrs[attr_name][:values] if _dynamic_attrs.key?(attr_name) && _dynamic_attrs[attr_name].key?(:values)
  end

  module ClassMethods

    def inherited(base) #:nodoc:
      super
      dup = _dynamic_attrs.dup
      base._dynamic_attrs = dup.each { |k, v| dup[k] = v.dup }
      base._dynamic_attr_state_if = Proc.new { false }
    end

    def clear_dynamic_attrs!
      self._dynamic_attrs = HashWithIndifferentAccess.new
      self._dynamic_attr_state_if = Proc.new { false }
    end

    def define_attr_state_if block
      _dynamic_attr_state_if = block
    end

    def define_attrs *args
      attrs = HashWithIndifferentAccess[*args.flatten]
      _dynamic_attrs.merge! attrs
      build_validations_from_dynamic_attrs attrs
    end

    def attrs_for state=nil, device=nil
      if state
        device ||= :desktop
        _dynamic_attrs.select do |key, val|
          if val.class == Symbol
            comparer = val
          elsif val.respond_to?(:key) && val.key?(:on)
            comparer = val[:on] if val[:on].class == Symbol
            comparer = val[:on][device] if val[:on].respond_to?(:key) && val[:on].key?(device)
          end

          [*comparer].map(&:to_sym).include? state.to_sym
        end
      else
        _dynamic_attrs
      end
    end

    def attrs_names_for state=nil, device=nil
      attrs_for(state, device).map(&:first)
    end

    def build_validations_from_dynamic_attrs attrs
      throw "No validation state if defined" unless _dynamic_attr_state_if
      attrs.each do |key, val|
        if val.class == ActiveSupport::HashWithIndifferentAccess && val.key?(:validates) && !val[:validates].empty?
          opts = val[:validates]
          # Check if validation should only be used in specific state
          if val.key?(:on)
            validates_on = val[:on]
            # If validates contains if statement, wrap that statement in state check
            if val[:validates].key?(:if)
              original_if = val[:validates][:if]
              opts.merge! if: ->(model) { model.instance_exec(validates_on, &_dynamic_attr_state_if) && model.instance_eval(&original_if) }
            else
              opts.merge! if: ->(model) { model.instance_exec(validates_on, &_dynamic_attr_state_if) }
            end
          end

          validates key, opts
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, DynamicAttributeDeclaration)