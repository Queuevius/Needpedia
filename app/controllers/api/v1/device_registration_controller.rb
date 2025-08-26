class Api::V1::DeviceRegistrationController < ApplicationController
  resource_description do
    name 'API v1 - Device Registration'
    short 'Register device tokens for notifications'
    api_versions 'v1'
  end

  api :POST, '/api/v1/register_device', 'Register a device for push notifications'
  param :uuid, String, required: true, desc: 'User UUID'
  param :registration_id, String, required: true, desc: 'Device registration/token id'
  def register_device
    user = User.find_by(uuid: params[:uuid])
    device = user.devices.find_or_create_by(registration_id: params[:registration_id])
    if device.save
      render json: {message: 'The device has been Successfully Registered.', success: true, status: 200, user: user}
    else
      render json: {success: false, message: device.errors.full_messages.uniq.join(', '), status: 400}
    end
  end
end
