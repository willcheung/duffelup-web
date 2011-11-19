module LikeHelper
  def liked?(event, from_event_show=nil) 
    return false if not logged_in?
    
    if from_event_show
      Like.find_by_user_id_and_event_id(current_user.id, event.id)
    else
      @likes.map(&:event_id).include?(event.id)
    end
  end
end
