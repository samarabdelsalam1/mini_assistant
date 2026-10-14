# app/models/product.rb
class Product < ApplicationRecord
  enum :status, { out_of_stock: 0, in_stock: 1 }

  validates :name, :slug, :price, presence: true
  validates :slug, uniqueness: true


end