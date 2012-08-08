ActiveRecord::Schema.define do
  self.verbose = false

  create_table :listings, :force => true do |t|
    t.string :name
    t.string :address
    t.timestamps
  end
end
