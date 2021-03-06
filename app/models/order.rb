# == Schema Information
#
# Table name: orders
#
#  id             :integer         not null, primary key
#  status         :string(255)
#  date_placed    :date
#  customer_id    :integer
#  customer_type  :string(255)
#  coordinator_id :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Order < ActiveRecord::Base
  STATUSES = %w(placed paid closed canceled)
  CUSTOMER_TYPES = %w(Client Company)

  belongs_to :customer, polymorphic: true, autosave: true
  belongs_to :coordinator, class_name: "Client", autosave: true

  has_many  :order_items, dependent: :destroy

  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :order_items, allow_destroy: true 
  accepts_nested_attributes_for :coordinator, allow_destroy: true 

  attr_accessible :customer_id, :customer_type, :date_placed, :status, :order_items_attributes, :customer_attributes, :coordinator_id, :coordinator_attributes, :terms
  
  validates :terms, :acceptance => true

  def customer_attributes=(attributes)
    # self.customer = eval(self.customer_type).where(email: attributes[:email]).first_or_initialize(attributes)
    self.customer = eval(self.customer_type).new(attributes)
  end

  def build_customer(params, assignment_options={})
    c_type = params[:customer_type]
    raise "Unknown customer_type: #{c_type}" unless CUSTOMER_TYPES.include?(c_type)
    new_params = params.reject!{ |k| k == :customer_type } 
    self.customer = c_type.constantize.new(new_params)
  end

  def coordinator_attributes=(attributes)
    unless attributes[:_destroy]=="1"
      # self.coordinator = Client.where(email: attributes[:email]).first_or_initialize(attributes.except(:_destroy))
      self.coordinator = Client.new(attributes.except(:_destroy))
    else
      self.coordinator = nil
    end
  end

  def build_coordinator(params={}, assignment_options={})
    self.coordinator = Client.new(params)
  end

  def total
    self.order_items.inject(0) do |acc, oi|
      acc + oi.quantity*oi.productable.price
    end
  end

end
