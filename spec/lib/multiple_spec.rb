  require 'spec_helper'

  describe "MULTIPLE MODELS TESTS" do

    before do
      [Phone, Car].each do |model|
        model.clear_validators!
        model.clear_dynamic_attrs!
      end
    end

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