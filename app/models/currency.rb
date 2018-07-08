class Currency < ApplicationRecord

  validates :code, presence: true,
                   uniqueness:{case_insensitive: true}
end
