class Admin::SmsMessagesController < AdminController

  def index
    @messages = SmsMessage.order("created_at DESC").page(params[:page])
  end

  def new
    @message = SmsMessage.new

    if params[:user_id]
      recipient = User.find(params[:user_id])
      @message.account_id     = recipient.account_id
      @message.user_id        = recipient.id
      @message.mobile_number  = recipient.notification_phone
    end
  end

  def create
    @message = SmsMessage.new(sms_message_params)

    unless @message.account_id
      # sms without user assign to first account (this should be demo account)
      @message.account_id = Account.active.order(:id).first.id
    end

    unless @message.valid?
      render :new
      return
    end

    if @message.send_via_api
      flash[:success] = "Sent to #{@message.mobile_number}"
      @message.save
      rw_redirect_back
    else
      @message.errors.add(:base, "Errors: #{@message.response}")
      render :new
    end
  end

  private

  def sms_message_params
    params.require(:sms_message).permit!
  end

end
