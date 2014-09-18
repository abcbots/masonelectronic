module Extensions
  module <%= (@alpha.camelize+@alpha.camelize).pluralize %>
  extend ActiveSupport::Concern
    included do
     
      attr_accessor :<%= @alpha %>_parent_id
      attr_accessor :<%= @alpha %>_child_id

      has_many :<%= @alpha+"_"+@alpha.pluralize %>, :foreign_key => 'parent_id'
      has_many :parent_<%= @alpha+"_"+@alpha.pluralize %>, :class_name => 'SpotSpot', :foreign_key => 'child_id'
      has_many :parents, :through => :parent_<%= @alpha+"_"+@alpha.pluralize %>, :source => :parent_<%= @alpha %>, :foreign_key => 'parent_id'
      has_many :child_<%= @alpha+"_"+@alpha.pluralize %>, :class_name => '<%= (@alpha.camelize+@alpha.camelize) %>', :foreign_key => 'parent_id'
      has_many :children, :through => :child_<%= @alpha+"_"+@alpha.pluralize %>, :source => :child_<%= @alpha %>, :foreign_key => 'child_id'

    end
  end
end
