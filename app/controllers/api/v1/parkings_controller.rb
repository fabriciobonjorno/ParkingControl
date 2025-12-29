# frozen_string_literal: true

class Api::V1::ParkingsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from StandardError, with: :unprocessable

  def create
    parking = Parkings::EnterService.call(plate: params[:plate])
    render json: ParkingPresenter.entrance_ticket(parking), status: :created
  end

  def pay
    Parkings::PayService.call(plate: params[:id])
    render json: { message: "Pagamento realizado com sucesso" }, status: :ok
  end

  def out
    Parkings::LeaveService.call(plate: params[:id])
    render json: { message: "Baixa realizado com sucesso" }, status: :ok
  end

  def history
    parkings = Parkings::HistoryService.call(plate: params[:plate])
    render json: ParkingPresenter.history(parkings), status: :ok
  end

  private

  def not_found
    render json: { error: "Invalid Plate" }, status: :not_found
  end

  def unprocessable(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
