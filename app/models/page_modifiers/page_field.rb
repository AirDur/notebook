#<PageField
#  id: nil,
#  label: nil,
#  page_category_id: nil,
#  field_type: "textarea",
#  created_at: nil,
#  updated_at: nil>
class PageField < ActiveRecord::Base
  belongs_to :user
  belongs_to :page_category
  has_many :page_field_values
end