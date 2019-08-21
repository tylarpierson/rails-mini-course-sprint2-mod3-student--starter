class Customer < ApplicationRecord
    has_many :orders

    validates :email, presence: true
end
