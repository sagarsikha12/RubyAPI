class Category < ApplicationRecord
    # Validations
    validates :name, presence: true, uniqueness: true

    # Associations
    has_many :campaigns, dependent: :destroy
end
