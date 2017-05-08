class Admin::UserEventsController < Admin::AdminApplicationController


  def edit
    @event = Event.find(params[:event_id])
    @user_event = @event.user_events.find(params[:id])
  end

  def update
    @event = Event.find(params[:event_id])
    @user_event = @event.user_events.find(params[:id])
    if @user_event.update_attributes(user_event_params)
      @user_event.update_attribute(:check_in, Time.zone.strptime(user_event_params[:check_in], '%m/%d/%Y %I:%M %p')) unless user_event_params[:check_in].nil?
      @user_event.update_attribute(:check_out, Time.zone.strptime(user_event_params[:check_out], '%m/%d/%Y %I:%M %p')) unless user_event_params[:check_out].nil?
      flash[:notice]="Updated Successfully"
      redirect_to admin_event_path(@event)
    else
      flash[:error]=@user_event.errors.full_messages.join(', ')
      redirect_to :back
    end
  end


  private
  def user_event_params
    params.require(:user_event).permit(:notes, :total_expense, :check_in, :check_out, :images, :follow_up, :recommended, :attendance, :sample)
  end

end