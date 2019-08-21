class Order < ApplicationRecord
  has_many :order_products
  has_many :products through :order_products
  belongs_to :customers

  def products
    product_ids = OrderProduct.where(order_id: id).pluck(:product_id)
    Product.find(product_ids)
  end

  def shippable?
    status != "shipped" && products.count >= 1
  end

  def ship
    shippable? && update(status: "shipped")
  end
end
