class Product < ApplicationRecord
  has_many :order_products
  has_many :orders through :order_products

  def available?
    inventory > 0
  end

  def reduce_inventory
    update(inventory: inventory - 1)
  end
end
