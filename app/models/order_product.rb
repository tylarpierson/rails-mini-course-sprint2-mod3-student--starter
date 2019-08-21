class OrderProduct < ApplicationRecord
    belongs_to :order, :product
end
