class Superadmin::ClientsController < Superadmin::SuperadminApplicationController


  def index
    @clients=Client.all.page(params[:page]).per(20)
  end

  def new
    @client=Client.new
    @admin=@client.users.new
    @brands= @client.brands.build
  end

  def create
    @client=Client.new(client_params)
    if client_params[:brands_attributes].nil?
      flash[:error]="Add Atleast one brand"
      redirect_to :back
      return
    end
    @client.users << @client.admin
    if @client.save
      redirect_to superadmin_clients_path
    else
      flash[:error]=@client.errors.full_messages.join(',')
      redirect_to :back
    end
  end

  def edit
    @client=Client.find(params[:id])
    @admin=@client.admin
    @brands=@client.brands
  end

  def update
    @client=Client.find(params[:id])
    client_call_params= client_params
    if client_params[:admin_attributes][:password].empty?
      client_call_params = client_update_params
    end
    if client_params[:brands_attributes].nil?
      flash[:error]="Add Atleast one brand"
      redirect_to :back
      return
    end
    if @client.update_attributes(client_call_params)
      redirect_to superadmin_clients_path
    else
      flash[:error]=@client.errors.full_messages.join(', ')
      redirect_to :back
    end
  end

  def impersonate
    client = Client.find(params[:client_id])
    slave_user = User.find(params[:user_id])
    if slave_user
      session[:slave_user_id] = slave_user.id
      session[:role] = 'super_admin'
      redirect_to admin_dashboard_index_path, :notice => "Logged in as #{slave_user.full_name}"
    else
      flash[:notice] = 'Sorry! You cannot login as this user'
      redirect_back fallback_location: superadmin_clients_path
    end

  end


  def remove_brand
    client = Client.find(params[:client_id])
    brand=client.brands.find(params[:id])
    brand.destroy
    render json: {success: :true}
  end

  private

  def client_params
    params.require(:client).permit(:name, :phone, :brand_ids, admin_attributes: [:id, :first_name, :last_name, :password, :password_confirmation, :email, :role, :image], brands_attributes: [:id, :name, :unit_cost])
  end

  def client_update_params
    params.require(:client).permit(:name, :phone, :brand_ids, admin_attributes: [:id, :first_name, :last_name, :email, :role, :client_id, :image], brands_attributes: [:id, :name, :unit_cost])
  end


end