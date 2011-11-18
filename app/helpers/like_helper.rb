module LikeHelper
  def liked?(event) 
    return false if not logged_in?
    @likes.map(&:event_id).include?(event.id)
  end
end
