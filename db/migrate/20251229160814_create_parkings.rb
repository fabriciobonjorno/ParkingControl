# frozen_string_literal: true

class CreateParkings < ActiveRecord::Migration[8.1]
  def change
    create_table :parkings do |t|
      t.string   :plate, null: false, index: true

      t.datetime :started_at, null: false, index: true
      t.datetime :paid_at, index: true
      t.datetime :left_at, index: true

      t.timestamps
    end
  end
end
