class TopController < ApplicationController
  def index
    @question = Question.new
    @feed_contents = current_user.group.feed_contents.includes(:content).page(params[:page]).per(5)
    @feed_contents_resource = @feed_contents.map(&:content)
  end

  def aftertime_comment?(text)
    if text.match(/.*以内.*/) != nil
      return ""
    else
      return "前"
    end
  end
  helper_method :aftertime_comment?

end
