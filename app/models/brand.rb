class Brand < ApplicationRecord
  has_many :brand_categories
  has_many :brand_categories, through: :set_brands
  has_many :products
end
class BrandCategory < ApplicationRecord
  has_many :brand_categories
  has_many :brand_categories, through: :set_brands
  has_many :toppages
end
