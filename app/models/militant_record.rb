require 'diff'

class MilitantRecord < ActiveRecord::Base
  include ActiveRecord::Diff
  diff exclude: [:created_at, :updated_at]
end
