class Api::V1::DeviceRegistrationController < ApplicationController
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
