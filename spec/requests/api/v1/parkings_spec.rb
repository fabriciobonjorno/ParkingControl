# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Parkings", type: :request do
  describe "POST /api/v1/parking" do
    context "with valid plate" do
      it "creates a new parking entry" do
        expect {
          post "/api/v1/parking", params: { plate: "ABC-1234" }
        }.to change(Parking, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          "plate" => "ABC-1234",
          "message" => "Entrada registrada com sucesso"
        )
      end
    end

    context "with invalid plate" do
      it "returns unprocessable content" do
        post "/api/v1/parking", params: { plate: "INVALID" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include("error" => "Invalid Plate")
      end
    end

    context "when vehicle is already parked" do
      let!(:existing_parking) { create(:parking, plate: "ABC-1234") }

      it "returns already active response" do
        post "/api/v1/parking", params: { plate: "ABC-1234" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          "message" => "Veículo já cadastrado e com estacionamento em aberto"
        )
      end
    end

    context "when vehicle is paid but not left" do
      let!(:existing_parking) { create(:parking, :paid, plate: "ABC-1234") }

      it "returns paid not left response" do
        post "/api/v1/parking", params: { plate: "ABC-1234" }

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["message"]).to include("Pagamento realizado")
      end
    end
  end

  describe "PUT /api/v1/parking/:id/pay" do
    context "with active parking" do
      let!(:parking) { create(:parking, plate: "ABC-1234") }

      it "processes payment successfully" do
        put "/api/v1/parking/ABC-1234/pay"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          "message" => "Pagamento realizado com sucesso"
        )
        expect(parking.reload.paid?).to be true
      end
    end

    context "with invalid plate" do
      it "returns unprocessable content" do
        put "/api/v1/parking/INVALID/pay"

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when no active parking exists" do
      it "returns unprocessable content" do
        put "/api/v1/parking/ABC-1234/pay"

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("Nenhum registro ativo")
      end
    end

    context "when already paid" do
      let!(:parking) { create(:parking, :paid, plate: "ABC-1234") }

      it "returns error message" do
        put "/api/v1/parking/ABC-1234/pay"

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("Pagamento já realizado")
      end
    end
  end

  describe "PUT /api/v1/parking/:id/out" do
    context "with paid parking" do
      let!(:parking) { create(:parking, :paid, plate: "ABC-1234") }

      it "processes exit successfully" do
        put "/api/v1/parking/ABC-1234/out"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          "message" => "Baixa realizado com sucesso"
        )
        expect(parking.reload.left?).to be true
      end
    end

    context "with unpaid parking" do
      let!(:parking) { create(:parking, plate: "ABC-1234") }

      it "returns payment required error" do
        put "/api/v1/parking/ABC-1234/out"

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("Pagamento não realizado")
      end
    end

    context "when no active parking exists" do
      it "returns error" do
        put "/api/v1/parking/ABC-1234/out"

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /api/v1/parking/:plate" do
    context "with valid plate" do
      let!(:parking1) { create(:parking, plate: "ABC-1234", started_at: 2.hours.ago) }
      let!(:parking2) { create(:parking, :completed, plate: "ABC-1234", started_at: 1.day.ago) }

      it "returns parking history" do
        get "/api/v1/parking/ABC-1234"

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.length).to eq(2)
        expect(body.first).to include("id", "time", "paid", "left")
      end
    end

    context "with invalid plate format" do
      it "returns unprocessable content" do
        get "/api/v1/parking/INVALID"

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with no parking history" do
      it "returns empty array" do
        get "/api/v1/parking/ABC-1234"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end
end
