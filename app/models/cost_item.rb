# == Schema Information
#
# Table name: cost_items
#
#  id          :integer         not null, primary key
#  quote_id    :integer
#  name        :string(255)
#  single_cost :integer
#  factor_type :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class CostItem < ActiveRecord::Base
  FACTOR_TYPES = { per_day: 'daily', per_person: 'person', per_event: 'globally' }
  
  belongs_to :quote

  attr_accessible :name, :single_cost, :factor_type

  #validates :name, presence: true
  validates :single_cost, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :factor_type, inclusion: { in: FACTOR_TYPES.keys.map {|k| k.to_s}, message: "%{value} is not a valid factor_type" }, allow_blank: true
  #validates :quote_id, presence: true

  default_scope :order => 'id'

  def factor_types
    FACTOR_TYPES
  end

  def cost_item_total
    factor = case factor_type
    when "per_day"
      self.quote.number_of_days
    when "per_person"
      self.quote.income_variants.find_by_currently_chosen(true).try(:number_of_participants)
    when "per_event"
      1
    end
    factor && single_cost ? single_cost*factor : 0
  end

end
