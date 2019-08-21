class Order < ApplicationRecord
  has_many :order_products
  has_many :products through :order_products
  belongs_to :customers

  validates :status, presence: true

  def shippable?
    status != "shipped" && products.count >= 1
  end

  def ship
    shippable? && update(status: "shipped")
  end
end
