class OrderProduct < ApplicationRecord
    belongs_to :orders :products
end
