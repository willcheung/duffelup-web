module LikeHelper
  def liked?(event_id, from_event_show=nil) 
    return false if not logged_in?
    
    if from_event_show
      Like.find_by_user_id_and_event_id(current_user.id, event_id)
    else
      @likes.map(&:event_id).include?(event_id)
    end
  end
end
