class ReservationsController < ApplicationController
  before_action :set_search_params, only: %i[show_search]
  before_action :set_reservation, only: %i[destroy]
  before_action :set_should_show_results, only: %i[show_search]
  before_action :check_dates, only: %i[show_search]

  def show_search
    @available_rooms = @should_show_results ? available_rooms : Room.none
  end

  def new
    @reservation = Reservation.new(reservation_params)
  end

  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to @reservation.room,
                  notice: "Reservation #{@reservation.code} was successfully created."
    else
      render action: :new
    end
  end

  def destroy
    if @reservation.destroy
      redirect_to room_path(@reservation.room),
                  notice: "Reservation #{@reservation.code} was successfully destroyed."
    else
      redirect_to room_path(@reservation.room),
                  alert: "You can't remove a ongoing reservation."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def set_search_params
    @number_of_guests = params[:number_of_guests]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  def set_should_show_results
    @should_show_results = @start_date.present? && @end_date.present? && @number_of_guests.present?
  end

  def check_dates
    return if @start_date.blank? && @end_date.blank?
    return if @start_date.to_date < @end_date.to_date

    @should_show_results = false
    redirect_to new_search_reservations_path,
      alert: "Initial date should be before the end date."
  end

  def available_rooms
    Room.with_capacity(@number_of_guests) - Room.not_available_at(@start_date, @end_date)
  end

  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date, :number_of_guests, :guest_name, :room_id)
  end
end
