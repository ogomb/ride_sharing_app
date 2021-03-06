class RidesController < ApplicationController

  before_action :set_ride, only: [:show, :edit, :update, :delete]
  before_action :set_rides, only: [:index]
  def index
    @my_rides = policy_scope(Ride.available_rides.distinct)
    @user = current_user
  end

  def new
    @ride = Ride.new
  end
  def home
    render 'home'
  end

  def create
    @user = current_user
    @ride = Ride.new(ride_params)
    @ride.author_id = @user.id
    if @ride.save
      flash[:notice] = 'Ride has been created.'
      User.transaction do
        @user.roles.build(ride_id: @ride.id, role: 'driver')

        if !@user.save
          flash.now[:alert] = 'User has not been updated.'
          raise ActiveRecord::Rollback
        end
      end
      redirect_to @ride
    else
      flash.now[:alert] = 'Ride has not been created'
      render 'new'
    end
  end

  def show
    authorize @ride, :show?
  end

  def edit
    authorize @ride, :update?
  end

  def update
    authorize @ride, :update?

    if @ride.update(ride_params)
      flash[:notice] = 'Ride has been updated.'
      redirect_to @ride
    else
      flash.now[:alert] = 'Ride has not been updated.'
      render 'edit'
    end
  end

  def add_ride
    @user = current_user
    User.transaction do
      role_data = params.fetch(:ride_id, [])
      role_data.each do |ride_id, role_name='editor'|
          @user.roles.build(ride_id: ride_id, role: role_name)
      end

      if !@user.save
        flash.now[:alert] = "User has not been updated."
        raise ActiveRecord::Rollback
      end
      redirect_to rides_path
    end
  end

  def destroy
    authorize @ride, :destroy
    @ride = Ride.find(params[:id])
    @ride.destroy

    flash[:notice] = "Ride has been deleted."
    redirect_to rides_path
  end

  private

  def set_rides
    @all_rides = Ride.available_rides
  end

  def ride_params
    params.require(:ride).permit(:destination, :departure_time, :passengers)
  end

  def set_ride
    @ride = Ride.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "the ride you were looking for could not be found."
    redirect_to rides_path
  end
end
