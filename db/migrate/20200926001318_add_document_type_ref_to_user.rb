class AddDocumentTypeRefToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :document_type, foreign_key: true
  end
end
