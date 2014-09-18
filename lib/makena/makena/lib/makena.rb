require "makena/version"
require "makena/tree"
require "makena/views"
require "makena/layouts"
require "makena/controllers"
require "pry" if (Rails.env.test? or Rails.env.development?)

module Makena

  include Tree
  include Views
  include Layouts
  include Controllers

end
