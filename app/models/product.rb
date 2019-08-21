class Product < ApplicationRecord
  has_many :order_products
  has_many :orders through :order_products

  validates :name, presence: true
  validates :cost_cents, presence: true, greater_than: 0
  validates :inventory, presence: true, greater_than_or_equal_to: 0



  def available?
    inventory > 0
  end

  def reduce_inventory
    update(inventory: inventory - 1)
  end
end
