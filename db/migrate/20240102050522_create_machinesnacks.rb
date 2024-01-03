class CreateMachinesnacks < ActiveRecord::Migration[7.0]
  def change
    create_table :machine_snacks do |t|
      t.references :machine, null: false, foreign_key: true
      t.references :snack, null: false, foreign_key: true

      t.timestamps
    end
  end
end
