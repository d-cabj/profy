class Group < ActiveRecord::Base
  has_many :users
  has_many :questions, ->{order("created_at desc")}
  has_many :feed_contents, ->{ order("updated_at DESC") }
end
