class User < ApplicationRecord
  devise :two_factor_authenticatable, :two_factor_backupable,
         otp_backup_code_length: 6, otp_number_of_backup_codes: 6,
         :otp_secret_encryption_key => ENV['OTP_KEY']

  include DeviseTokenAuth::Concerns::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, :confirmable, :lockable, :invitable, omniauth_providers: [:google_oauth2, :facebook]


  after_create :add_default_credit, :create_admin_notifications, :make_friend_with_mascot, :create_user_tutorials
  before_destroy :delete_notifications
  # before_create :skip_confirmation_notification!

  before_create :initialize_reset_password_tracking

  after_update :clear_reset_password_attempts, if: :encrypted_password_changed?

  validate :password_complexity

  after_create :create_ai_tokens

  has_rich_text :about

  has_person_name
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships, dependent: :destroy
  has_many :requests, dependent: :destroy

  has_many :notifications, foreign_key: :recipient_id
  has_many :services, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :posted_gigs, class_name: 'Gig', dependent: :destroy

  has_many :transferred_transactions, class_name: 'Transaction', foreign_key: :actor_id
  has_many :received_transactions, class_name: 'Transaction', foreign_key: :recipient_id

  has_many :user_posts, dependent: :destroy
  has_many :tracking_posts, class_name: 'UserPost', dependent: :destroy

  has_many :user_gigs
  has_many :gigs, through: :user_gigs, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :objectives, dependent: :destroy
  has_many :related_contents, dependent: :destroy

  has_many :flags, dependent: :destroy

  has_many :post_tokens, dependent: :destroy

  has_many :likes, dependent: :destroy

  has_many :ratings, dependent: :destroy

  has_many :shares, dependent: :destroy

  has_many :connections
  has_many :friends, through: :connections

  has_many :inverse_connections, class_name: 'Connection', foreign_key: 'friend_id'
  has_many :inverse_friends, through: :inverse_connections, source: :user

  has_many :connection_requests, dependent: :destroy

  has_one_attached :profile_image

  has_many_attached :pictures

  has_many :messages, dependent: :destroy

  has_many :user_conversations, dependent: :destroy
  has_many :conversations, through: :user_conversations

  has_many :user_questionnaires, dependent: :destroy
  has_many :questionnaires, through: :user_questionnaires

  has_many :answers, dependent: :destroy

  has_many :blocked_users, dependent: :destroy
  has_many :notification_settings, dependent: :destroy

  has_many :feedbacks, dependent: :destroy
  has_many :deletions, dependent: :destroy
  has_many :devices, dependent: :destroy

  has_many :user_tutorials, dependent: :destroy
  has_many :topics, dependent: :destroy

  has_many :chat_threads
  belongs_to :current_chat_thread, class_name: 'ChatThread', optional: true
  has_many :impacts, dependent: :destroy

  has_many :ai_tokens, dependent: :destroy

  MAX_RESET_PASSWORD_ATTEMPTS = 5
  RESET_ATTEMPT_WINDOW = 24.hours

  def credit_hours
    active_gigs_amount = posted_gigs.active_progress.sum(:amount)
    sum = (received_transactions&.sum(:amount) - transferred_transactions&.sum(:amount) - active_gigs_amount).round(1)
    sum.negative? ? 0 : sum
  end

  def add_default_credit
    TransactionService.new(actor: nil, recipient: self, gig: nil, amount: 1, type: Transaction::TRANSACTION_TYPE_DEFAULT).call
  end

  def create_admin_notifications
    notifications = AdminNotification.where(audience: [AdminNotification::ALL, AdminNotification::NEW_COMERS])
    admin = User.where(admin: true)&.first
    return unless notifications.present? && admin.present?

    notifications.each do |notification|
      Notification.post(from: admin, notifiable: admin, to: self, action: Notification::NOTIFICATION_TYPE_ADMIN_NOTIFICATION, admin_notification_id: notification.id)
    end
  end

  def make_friend_with_mascot
    return if mascot.blank?

    Connection.create(user_id: id, friend_id: mascot.id)
  end

  def mascot
    User.find_by(email: 'mascotaccount@needpedia.com')
  end

  def connection_status(current_user)
    if is_connected_with current_user
      state = { status: 'connected' }
    elsif ConnectionRequest.find_by user_id: current_user.id, to: self.uuid, status: 'pending'
      request = ConnectionRequest.find_by user_id: current_user.id, to: self.uuid, status: 'pending'
      state = {status: 'request_sent', request_uuid: request.uuid}
    elsif ConnectionRequest.find_by user_id: self.id, to: current_user.uuid, status: 'pending'
      request = ConnectionRequest.find_by user_id: self.id, to: current_user.uuid, status: 'pending'
      state = { status: 'request_received', request_uuid: request.uuid }
    else
      state = { status: 'not_connected' }
    end
    state
  end

  # this method returns the user connections and inverse connections
  def links
    self.friends + self.inverse_friends
  end

  # this method checks if a link exist between current user and the user in sent in argument
  def is_connected_with(user)
    links.include? user
  end

  def delete_notifications
    notifications = Notification.where("actor_id = ? OR recipient_id = ?", self.id, self.id)
    notifications.destroy_all if notifications.present?
  end

  def password_complexity
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*_-])/

    errors.add :password, 'Complexity requirement not met. Please use: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
  end

  ransacker :full_name, formatter: proc { |v| v.mb_chars.downcase.to_s } do |parent|
    Arel::Nodes::NamedFunction.new('LOWER',
                                   [Arel::Nodes::NamedFunction.new('concat_ws',
                                                                   [Arel::Nodes::SqlLiteral.new("' '"), parent.table[:first_name], parent.table[:last_name]])])
  end

  def create_user_tutorials
    Tutorial.all.each do |tutorial|
      self.user_tutorials.create(link: tutorial.link, content: tutorial.content)
    end
  end

  def otp_qr_code
    self.update(otp_secret: User.generate_otp_secret) unless otp_secret.present?
    issuer = "#{Rails.application.class.module_parent_name}-#{Rails.env}"
    label = "#{issuer}:#{email}"
    qrcode = RQRCode::QRCode.new(otp_provisioning_uri(label, issuer: issuer))
    qrcode.as_svg(module_size: 4)
  end

  def self.features
    ENV['FEATURES'].split(',').map(&:strip)
  end

  def feature_enabled?(feature)
    features[feature.to_s] == true
  end

  def send_reset_password_instructions
    if reset_password_attempts_exceeded?
      errors.add(:base, "You have reached the maximum number of password reset attempts for today. Please try again later.")
      return false
    end

    update_reset_password_tracking
    super
  end

  def self.from_omniauth(auth)
    # Log the auth data received
    Rails.logger.debug "Processing auth data: #{auth.inspect}"
    
    # Check if email is present in the auth data
    if auth.info.email.blank?
      # Generate a temporary email using the provider UID if no email is provided
      temp_email = "#{auth.uid}-#{auth.provider}@needpedia.example"
      Rails.logger.debug "No email provided by #{auth.provider}, using temporary email: #{temp_email}"
    else
      temp_email = auth.info.email
    end
    
    # Find existing user by provider and uid or email
    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = temp_email
      user.password = Users::OmniauthCallbacksController.new.send(:generate_secure_password)
      user.name = auth.info.name || "#{auth.info.first_name} #{auth.info.last_name}"
      
      # Populate any other fields from auth.info if needed
      # user.image = auth.info.image # if you have an image field
    end
    
    # Update user with latest info from provider
    if user.persisted?
      Rails.logger.debug "User found, updating from auth data"
      user.update(
        name: auth.info.name,
        # Any other fields you want to update
        last_sign_in_at: Time.current
      )
    else
      Rails.logger.debug "New user created from auth data"
    end
    
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.google_oauth2_data"] && session["devise.google_oauth2_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.first_name = data["given_name"] if user.first_name.blank?
        user.last_name = data["family_name"] if user.last_name.blank?
      end
    end
  end

  private

  def initialize_reset_password_tracking
    self.reset_password_attempts = 0
    self.last_reset_attempt_at = nil
  end

  def reset_password_attempts_exceeded?
    if last_reset_attempt_at.nil? || last_reset_attempt_at < RESET_ATTEMPT_WINDOW.ago
      self.reset_password_attempts = 0
    end

    reset_password_attempts >= MAX_RESET_PASSWORD_ATTEMPTS
  end

  def update_reset_password_tracking
    self.reset_password_attempts ||= 0
    self.reset_password_attempts += 1
    self.last_reset_attempt_at = Time.current
    save(validate: false)
  end


  def clear_reset_password_attempts
    update_columns(reset_password_attempts: 0, last_reset_attempt_at: nil)
  end

  def create_ai_tokens
    self.ai_tokens.create
  end
end
