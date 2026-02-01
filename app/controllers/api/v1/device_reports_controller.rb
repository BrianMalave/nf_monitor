class Api::V1::DeviceReportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = device_report_params
    ProcessDeviceReportJob.perform_later(payload)
    render json: { ok: true, queued: true }, status: :accepted
  rescue ActionController::ParameterMissing => e
    render json: { ok: false, error: "parameter_missing", details: [e.message] }, status: :unprocessable_entity
  end

  private

  def device_report_params
    params.require(:report).permit(
      restaurant: [:name, :city],
      devices: [
        :identifier,
        :kind,
        :status,
        { meta: {} },
        { maintenance: [:action, :notes, :started_at, :ended_at] }
      ]
    ).to_h.deep_symbolize_keys
  end
end