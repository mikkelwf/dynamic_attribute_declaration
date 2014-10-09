require 'spec_helper'

describe "BASE TESTS" do

  let(:cls) { Phone }

  before do
    cls.clear_validators!
    cls.clear_dynamic_attrs!
  end

  describe "Basic gem tests" do

    it "Accessor _dynamic_attrs should be Hash" do
      expect(cls._dynamic_attrs.class).to eq Hash
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

    describe "Simple definition of on" do

      types = {
        "on a symbol" => :right,
        "on an array" => [:right],
        "on a hash" => { all: :right }
      }

      types.each do |name, definition|
        describe name do
          before do
            cls.clear_dynamic_attrs!
            cls.define_attrs [
              {
                name: { on: definition }
              }
            ]
          end

          describe "_dynamic_attrs" do
            it "Should hold an array comparable to the definition" do
              expect(cls._dynamic_attrs[:name]).not_to eq nil
              expect(cls._dynamic_attrs[:name].class).to eq Array
              expect(cls._dynamic_attrs[:name].length).to eq 1
            end
            it "Should hold on defintions comparable to the definition" do
              cls._dynamic_attrs[:name].each do |attr|
                expect(attr[:on].class).to eq Hash
                expect(attr[:on].length).to eq 1
              end
            end
          end

          describe 'attrs_for' do
            it "With no state should return definition" do
              expect(cls.attrs_for.keys).to eq [:name]
            end
            it "With :all state should return definition" do
              expect(cls.attrs_for(:all).keys).to eq [:name]
            end
            it "With right state should return definition" do
              expect(cls.attrs_for(:right).keys).to eq [:name]
            end
            it "With wrong state should return definition" do
              expect(cls.attrs_for(:wrong).keys).to eq []
            end
          end

          describe 'attrs_names_for' do
            it "With no state should return definition" do
              expect(cls.attrs_names_for).to eq [:name]
            end
            it "With :all state should return definition" do
              expect(cls.attrs_names_for(:all)).to eq [:name]
            end
            it "With right state should return definition" do
              expect(cls.attrs_names_for(:right)).to eq [:name]
            end
            it "With wrong state should return definition" do
              expect(cls.attrs_names_for(:wrong)).to eq []
            end
          end
        end
      end
    end

    describe "Advanced definition of on" do
      before do
        @definition = [
          {
            name: { on: :foo }
          },
          {
            name: { on: :bar }
          }
        ]
        cls.define_attrs @definition
      end

      describe "_dynamic_attrs" do
        it "Should hold a hash for the defines on" do
          expect(cls._dynamic_attrs[:name]).not_to eq nil
          expect(cls._dynamic_attrs[:name].class).to eq Array
          expect(cls._dynamic_attrs[:name].length).to eq 2
        end
      end

      describe 'attrs_names_for' do
        it "With no state should return definition" do
          expect(cls.attrs_names_for).to eq [:name]
        end
        it "With :all state should return definition" do
          expect(cls.attrs_names_for(:all)).to eq [:name]
        end
        it "With foo state should return definition" do
          expect(cls.attrs_names_for(:foo)).to eq [:name]
        end
        it "With bar state should return definition" do
          expect(cls.attrs_names_for(:bar)).to eq [:name]
        end
        it "With wrong state should return definition" do
          expect(cls.attrs_names_for(:wrong)).to eq []
        end
      end
    end

    describe "Simple definition of presence validator" do
      before do
        @definition = [
          {
            name:
            {
              validates: { presence: true }
            }
          }
        ]
        @definition_keys = @definition.map { |d| d.keys }.flatten
        cls.define_attrs @definition
      end

      describe "validators" do
        it "Should have at least one validator" do
          expect(cls.validators).not_to eq []
          expect(cls.validators.length).to be >= 1
        end

        it "Should have validators from definition" do
          definition_validators = @definition.map { |obj|obj.keys.map { |k| obj[k][:validates] } }.flatten
          definition_validator_classes = definition_validators.map { |validator| validator.keys.map { |k| "ActiveRecord::Validations::#{k.capitalize}Validator".constantize } }.flatten

          expect(cls.validators.length).to eq definition_validators.length
          expect(cls.validators.map(&:class)).to eq definition_validator_classes
        end
      end

      describe "_dynamic_attrs" do
        it "Should have keys from definition" do
          expect(cls._dynamic_attrs.keys).to eq @definition_keys
        end
      end

      describe "attrs_for" do
        it "With no state should have the same keys as the definition" do
          response = cls.attrs_for
          expect(response.class).to eq Hash
          expect(cls.attrs_for.keys).to eq @definition_keys
          expect(cls.attrs_for.keys.length).to eq @definition_keys.length
        end
      end

      describe "attrs_names_for" do
        it "With no state should return definition" do
          expect(cls.attrs_names_for).to eq @definition_keys
        end
      end
    end

    describe "Simple definition of presence validator, with on parameter" do
      before do
        @definition = [
          {
            name:
            {
              validates: { presence: true },
              on: :right
            }
          }
        ]
        @definition_keys = @definition.map { |d| d.keys }.flatten
        cls.define_attrs @definition
      end

      it "Should have at least one validator" do
        expect(cls.validators).not_to eq []
        expect(cls.validators.length).to be >= 1
      end

      it "Should have validators from definition" do
        definition_validators = @definition.map { |obj|obj.keys.map { |k| obj[k][:validates] } }.flatten
        definition_validator_classes = definition_validators.map { |validator| validator.keys.map { |k| "ActiveRecord::Validations::#{k.capitalize}Validator".constantize } }.flatten

        expect(cls.validators.length).to eq definition_validators.length
        expect(cls.validators.map(&:class)).to eq definition_validator_classes
      end

      it "_dynamic_attrs should have keys from definition" do
        expect(cls._dynamic_attrs.keys).to eq @definition_keys
      end

      describe "attrs_for" do
        it "with no state should return definition" do
          expect(cls.attrs_for.keys).to eq @definition_keys
        end
        describe "with right state" do
          it "with symbol should return definition" do
            expect(cls.attrs_for(:right).keys).to eq @definition_keys
          end
          it "with string should return definition" do
            expect(cls.attrs_for("right").keys).to eq @definition_keys
          end
        end
        describe "with wrong state" do
          it "with symbol should return empty object" do
            expect(cls.attrs_for(:wrong).keys).to eq []
          end
          it "with string should return empty object" do
            expect(cls.attrs_for("wrong").keys).to eq []
          end
        end
      end

      describe "attrs_names_for" do
        it "with no state should return definition keys" do
          expect(cls.attrs_names_for).to eq @definition_keys
        end
        describe "with right state" do
          it "with symbol should return definition keys" do
            expect(cls.attrs_names_for(:right)).to eq @definition_keys
          end
          it "with string should return definition keys" do
            expect(cls.attrs_names_for("right")).to eq @definition_keys
          end
        end
        describe "with wrong state" do
          it "with symbol should return empty array" do
            expect(cls.attrs_names_for(:wrong)).to eq []
          end
          it "with string should return empty array" do
            expect(cls.attrs_names_for("wrong")).to eq []
          end
        end
      end

      describe "values_for" do
        pending "TEST VALUES FOR"
      end
    end
  end

  describe "Defining define_attr_state_if" do
    before do
      cls.clear_dynamic_attrs!
    end

    it "Should have no _dynamic_attr_state_if as standard" do
      expect(cls._dynamic_attr_state_if).to be_nil
    end

    it "lala" do
      proc = Proc.new { true }
      cls.define_attr_state_if proc
      expect(cls._dynamic_attr_state_if).to eq proc
    end
  end
end