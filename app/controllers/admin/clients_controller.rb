class Admin::ClientsController < Admin::AdminApplicationController

  def reps_and_groups
    match=[]
    @groups=Group.where("name ILIKE? ", "%#{params[:term]}%").order('name ASC')
    @users=User.where(:role=>:promo_rep).where("first_name ILIKE :search OR last_name ILIKE :search", search: "%#{params[:term]}%")
    @users.each do |user|
      match << {id: user.id, label: user.full_name, value: user.full_name, type: user.role}
    end
    @groups.each do |group|
      match << {id: group.id, label: group.name, value: group.name, type: 'promo_group'}
    end
    respond_to do |format|
      format.html
      format.json {
        render json: match
      }
    end
  end

  def edit
    @client=Client.find(params[:id])
    @admin=@client.admin
  end

  def update
    @client=Client.find(params[:id])
    client_call_params= client_params
    if client_params[:admin_attributes][:password].empty?
      client_call_params = client_update_params
    end
    if @client.update_attributes(client_call_params)
      @client.update(brand_ids: params[:client][:brand_ids]) if params[:client][:brand_ids]
      redirect_to admin_dashboard_index_path
    else
      flash[:error]=@client.errors.full_messages.join(', ')
      redirect_to edit_admin_client_path(@client)
    end
  end

  private

  def client_params
    params.require(:client).permit(:name, :phone, :brand_ids, admin_attributes: [:id, :first_name, :last_name, :password, :password_confirmation, :email, :role, :image])
  end

  def client_update_params
    params.require(:client).permit(:name, :phone, :brand_ids, admin_attributes: [:id, :first_name, :last_name, :email, :role, :client_id, :image])
  end

end
