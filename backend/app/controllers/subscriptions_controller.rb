class SubscriptionsController < ApplicationController
  include Internationalized
  around_action :switch_locale
  before_action :set_event, except: [:list]

  skip_before_action :verify_authenticity_token

  rescue_from Errors::EventNotFound, with: :render_not_found
  rescue_from Errors::TeamNotFound, with: :render_not_found

  def create
    message = SubscriptionManager.create_subscription(params[:subscription][:team], subscription_params)

    render json: { message: message }
  end

  def destroy
    message = SubscriptionManager.delete_subscription(params[:subscription][:team], subscription_params)

    render json: { message: message }
  end

  def list
    message = SubscriptionManager.list_active_subscriptions(subscription_params)

    render json: { message: message }
  end

  private

  def subscription_params
    params.require(:subscription).permit(:service, :conversation_id)
  end

  def render_not_found(err)
    render json: { message: err.to_s }, status: 400
  end
end
