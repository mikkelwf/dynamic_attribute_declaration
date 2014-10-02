require 'spec_helper'

describe "MODEL INSTANCE TESTS" do
  let(:cls) { Phone }

  before do
    cls.clear_validators!
    cls.clear_dynamic_attrs!

    cls.define_attr_state_if Proc.new { |value|
      self.validator value
    }
  end

  ## WITH NO VALIDATOR ##
  describe "With no validator" do
    it "Should be valid" do
      instance = cls.new
      instance.valid?
      expect(instance.valid?).to eq true
      expect(instance.errors.full_messages).to eq []
    end
  end
  ## WITH NO VALIDATOR - END ##

  describe "With validator" do

    describe "Without if" do
      ## WITH VALIDATOR - WITHOUT STATE ##
      describe "Without state" do
        before do
          cls.define_attrs  name: {
                              validates: { presence: true }
                            }
          @instance = cls.new
        end

        it "Should not be valid when having no value" do
          @instance.valid?
          expect(@instance.valid?).to eq false
          expect(@instance.errors.full_messages).not_to eq []
        end
        it "Should be valid when having a value" do
          @instance.name = 'My Phone'
          @instance.valid?
          expect(@instance.valid?).to eq true
          expect(@instance.errors.full_messages).to eq []
        end
      end
      ## WITH VALIDATOR - WITHOUT STATE - END ##

      ## WITH VALIDATOR - WITH STATE ##
      describe "With state" do
        before do
          cls.define_attrs  name: {
                              validates: { presence: true },
                              on: :right
                            }
          @instance = cls.new
        end

        describe "With right validatable state" do
          before do
            @instance.state = :right
          end

          it "Should not be valid when having no value" do
            @instance.valid?
            expect(@instance.valid?).to eq false
            expect(@instance.errors.full_messages).not_to eq []
          end
          it "Should be valid when having a value" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
          end
        end

        describe "With wrong validatable state" do
          before do
            @instance.state = :wrong
          end

          it "Should be valid when having no value" do
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
          end
          it "Should be valid when having a value" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
          end
        end

        describe "With no validatable state" do
          it "Should be valid when having no value" do
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
          end
          it "Should be valid when having a value" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
          end
        end
      end
      ## WITH VALIDATOR - WITH STATE ##
    end


    describe "With if statement" do
      ## WITH VALIDATOR - WITHOUT STATE ##
      describe "Without state" do
        before do
          cls.define_attrs  name: {
                              validates: { presence: true }
                            },
                            model: {
                              validates: {
                                presence: true,
                                if: ->(state){ !!name }
                              },
                            }
          @instance = cls.new
        end

        it "Should not be valid when having no values" do
          @instance.valid?
          expect(@instance.class._validators).not_to eq({})
          expect(@instance.valid?).to eq false
          expect(@instance.errors.full_messages).not_to eq []
          expect(@instance.errors.full_messages_for(:name)).to eq ["Name can't be blank"]
          expect(@instance.errors.full_messages_for(:model)).to eq []
        end
        it "Should not be valid when having set only the non-dependent attribute" do
          @instance.name = 'My Phone'
          @instance.valid?
          expect(@instance.valid?).to eq false
          expect(@instance.errors.full_messages).not_to eq []
          expect(@instance.errors.full_messages_for(:name)).to eq []
          expect(@instance.errors.full_messages_for(:model)).to eq ["Model can't be blank"]
        end
        it "Should not be valid when having set only the dependent attribute" do
          @instance.model = 'The Awesome Phone'
          @instance.valid?
          expect(@instance.valid?).to eq false
          expect(@instance.errors.full_messages).not_to eq []
          expect(@instance.errors.full_messages_for(:name)).to eq ["Name can't be blank"]
          expect(@instance.errors.full_messages_for(:model)).to eq []
        end
        it "Should be valid when having set both attributes" do
          @instance.name = 'My Phone'
          @instance.model = 'The Awesome Phone'
          @instance.valid?
          expect(@instance.valid?).to eq true
          expect(@instance.errors.full_messages).to eq []
          expect(@instance.errors.full_messages_for(:name)).to eq []
          expect(@instance.errors.full_messages_for(:model)).to eq []
        end
      end
      ## WITH VALIDATOR - WITHOUT STATE - END ##

      ## WITH VALIDATOR - WITH STATE ##
      describe "With state" do
        before do
          cls.define_attrs  name: {
                              validates: { presence: true },
                              on: :right
                            },
                            model: {
                              validates: {
                                presence: true,
                                if: ->(state){ !!name }
                              },
                              on: :right
                            }
          @instance = cls.new
        end

        describe "With right validatable state" do

          before do
            @instance.state = :right
          end

          it "Should not be valid when having no values" do
            @instance.valid?
            expect(@instance.valid?).to eq false
            expect(@instance.errors.full_messages).not_to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq ["Name can't be blank"]
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should not be valid when having set only the non-dependent attribute" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq false
            expect(@instance.errors.full_messages).not_to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq ["Model can't be blank"]
          end
          it "Should not be valid when having set only the dependent attribute" do
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq false
            expect(@instance.errors.full_messages).not_to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq ["Name can't be blank"]
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set both attributes" do
            @instance.name = 'My Phone'
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
        end

        describe "With wrong validatable state" do

          before do
            @instance.state = :wrong
          end

          it "Should be valid when having no values" do
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set only the non-dependent attribute" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set only the dependent attribute" do
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set both attributes" do
            @instance.name = 'My Phone'
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end

        end

        describe "With no validatable state" do
          it "Should be valid when having no values" do
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set only the non-dependent attribute" do
            @instance.name = 'My Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set only the dependent attribute" do
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
          it "Should be valid when having set both attributes" do
            @instance.name = 'My Phone'
            @instance.model = 'The Awesome Phone'
            @instance.valid?
            expect(@instance.valid?).to eq true
            expect(@instance.errors.full_messages).to eq []
            expect(@instance.errors.full_messages_for(:name)).to eq []
            expect(@instance.errors.full_messages_for(:model)).to eq []
          end
        end
      end
      ## WITH VALIDATOR - WITH STATE ##
    end
  end
end