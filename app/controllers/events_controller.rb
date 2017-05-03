class EventsController < ApplicationController

  # skip_before_filter :authenticate_user_from_token!, :only => [:show]

  def show
    @event=Event.find(params[:id])
    if params[:token]
      user_event=UserEvent.find_by(token: params[:token])
      if params[:status]=="accept"
        if @event.promo_rep?
          user_event.status = :accepted
          user_event.save
          flash[:notice]= "Event accepted sucessfully"
        elsif @event.promo_group?
          if @event.max_users > @event.user_events.where(:status => UserEvent::statuses[:accepted]).count
            user_event.status = :accepted
            user_event.save
            flash[:notice]= "Event accepted sucessfully"
          else
            flash[:notice]= "Event reached max no of users"
          end
        end
      elsif params[:status]=="decline"
        user_event.status = :declined
        user_event.save
        flash[:notice]= "Event declined "
      end
    end
  end

end

