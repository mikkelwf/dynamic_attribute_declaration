require 'spec_helper'

describe "Dynamic Attribute Declaration" do

  before do
    [Phone, Car].each do |model|
      model.clear_validators!
      model.clear_dynamic_attrs!
      # model._dynamic_attrs = HashWithIndifferentAccess.new
      # model._dynamic_attr_state_if = Proc.new { true }
    end
  end

  let(:cls) { Phone }

  describe "Basic gem tests" do

    it "Accessor _dynamic_attrs should be HashWithIndifferentAccess" do
      expect(cls._dynamic_attrs.class).to eq HashWithIndifferentAccess
    end

    %w(define_attrs attrs_for attrs_names_for build_validations_from_dynamic_attrs).each do |attr|
      it "Should respond to #{attr}" do
        expect(cls).to respond_to(attr.to_sym)
      end
    end
  end

  describe "Defining attrs" do

    it "Clean Model should have no validators" do
      expect(cls.validators).to eq []
    end

    describe "Simple definition of presence validator" do
      let(:defition_array) { [{name:{validates:{presence: true}}}] }
      let(:definition) { HashWithIndifferentAccess[*defition_array.flatten] }

      before do
        cls.define_attrs definition
      end

      it "Should have at least one validator" do
        expect(cls.validators).not_to eq []
        expect(cls.validators.length).to be >= 1
      end

      it "Should have a specific validator" do
        obj = definition
        name = obj.keys.first
        validators = obj[name][:validates]
        validator_type = validators.keys.first

        validator = cls.validators.first
        expect(validator.class).to eq "ActiveRecord::Validations::#{validator_type.capitalize}Validator".constantize
      end

      it "_dynamic_attrs should have configuration from define_attrs" do
        expect(cls._dynamic_attrs).to eq definition
      end

      it "attrs_for with no state should return definition" do
        expect(cls.attrs_for).to eq definition
      end

      it "attrs_names_for with no state should return definition" do
        expect(cls.attrs_names_for).to eq definition.keys
      end
    end

    describe "Simple definition of presence validator, with on parameter" do
      let(:defition_array) { [{name:{validates:{presence: true}, on: :right}}] }
      let(:definition) { HashWithIndifferentAccess[*defition_array.flatten] }
      let(:instance) { cls.new }

      before do
        cls.define_attrs definition
      end

      it "Should have at least one validator" do
        expect(cls.validators).not_to eq []
        expect(cls.validators.length).to be >= 1
      end

      it "Should have a specific validator" do
        obj = definition
        name = obj.keys.first
        validators = obj[name][:validates]
        validator_type = validators.keys.first

        validator = cls.validators.first
        expect(validator.class).to eq "ActiveRecord::Validations::#{validator_type.capitalize}Validator".constantize
      end

      it "_dynamic_attrs should have configuration from define_attrs" do
        expect(cls._dynamic_attrs).to eq definition
      end

      describe "attrs_for" do
        it "with no state should return definition" do
          expect(cls.attrs_for).to eq definition
        end
        it "with right state should return definition" do
          expect(cls.attrs_for(:right)).to eq definition
        end
        it "with wrong state should return empty object" do
          expect(cls.attrs_for(:wrong)).to eq({})
        end
      end

      describe "attrs_names_for" do
        it "with no state should return definition keys" do
          expect(cls.attrs_names_for).to eq definition.keys
        end
        it "with right state should return definition keys" do
          expect(cls.attrs_names_for(:right)).to eq definition.keys
        end
        it "with wrong state should return empty array" do
          expect(cls.attrs_names_for(:wrong)).to eq []
        end
      end
    end
  end

  describe "Model Instance" do
    let(:cls) { Phone }

    describe "With no validator" do
      let(:instance) { cls.new }

      it "Should be valid" do
        instance.valid?
        expect(instance.valid?).to eq true
        expect(instance.errors.full_messages).to eq []
      end
    end

    describe "With validator" do
      let(:defition_array) { [{name:{validates:{presence: true}, on: :right}}] }
      let(:definition) { HashWithIndifferentAccess[*defition_array.flatten] }
      let(:instance) { cls.new }

      before do
        cls.define_attr_state_if Proc.new { |value| self.validator value }
        cls.define_attrs definition
      end

      describe "With validatable state" do
        before do
          instance.state = :right
        end

        it "Should not be valid when having no value" do
          instance.valid?
          expect(instance.valid?).to eq false
          expect(instance.errors.full_messages).not_to eq []
        end
        it "Should be valid when having a value" do
          instance.name = 'My Phone'
          instance.valid?
          expect(instance.valid?).to eq true
          expect(instance.errors.full_messages).to eq []
        end
      end

      describe "With non validatable state" do
        before do
          instance.state = :wrong
        end

        it "Should be valid when having no value" do
          instance.valid?
          expect(instance.valid?).to eq true
          expect(instance.errors.full_messages).to eq []
        end
        it "Should be valid when having a value" do
          instance.name = 'My Phone'
          instance.valid?
          expect(instance.valid?).to eq true
          expect(instance.errors.full_messages).to eq []
        end
      end

      describe "With no validatable state" do
        it "Should be valid when having no value" do
          instance.valid?
          expect(instance.valid?).to eq true
          expect(instance.errors.full_messages).to eq []
        end
        it "Should be valid when having a value" do
          instance.name = 'My Phone'
          instance.valid?
          expect(instance.valid?).to eq true
          expect(instance.errors.full_messages).to eq []
        end
      end
    end
  end

  describe "Multiple models" do

    it "_dynamic_attrs should be different" do
      expect(Phone._dynamic_attrs).to eq({})
      expect(Car._dynamic_attrs).to eq({})

      Phone.define_attrs [{name:{validates:{presence: true}, on: :right}}]
      Car.define_attrs [{name:{validates:{presence: true}, on: :another}}]
      expect(Phone._dynamic_attrs).not_to eq({})
      expect(Car._dynamic_attrs).not_to eq({})

      expect(Phone._dynamic_attrs).not_to eq Car._dynamic_attrs
    end
  end
end