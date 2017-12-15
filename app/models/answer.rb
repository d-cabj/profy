class Answer < ActiveRecord::Base
  #callback
  after_create :create_feed_content
  after_update :update_feed_content

  belongs_to :user
  belongs_to :question
  has_one :feed_content, as: :content, dependent: :destroy

  #validation
  validates_presence_of :user_id, :text

  private
  def create_feed_content
    self.feed_content = FeedContent.create(group_id: question.group_id, updated_at: updated_at)
  end
  def update_feed_content
    self.feed_content.update(updated_at: updated_at)
  end
end
