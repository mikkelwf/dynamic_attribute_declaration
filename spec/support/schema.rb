ActiveRecord::Schema.define do
  self.verbose = false

  create_table :phones, force: true do |t|
    t.string :name
    t.string :model
    t.timestamps
  end
end