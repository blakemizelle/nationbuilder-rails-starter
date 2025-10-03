class Installation < ApplicationRecord
  # Encrypt tokens at rest (Rails 7 built-in encryption)
  encrypts :access_token
  encrypts :refresh_token
  
  # Validations
  validates :nation_slug, presence: true, uniqueness: true
  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
  validates :status, inclusion: { in: %w[active expired uninstalled] }
  
  # Scopes
  scope :active, -> { where(status: "active") }
  scope :expired, -> { where("expires_at < ?", Time.current) }
  scope :expiring_soon, ->(buffer = 30.minutes) { where("expires_at < ?", buffer.from_now) }
  scope :inactive, ->(days = 30) { where("last_used_at < ?", days.days.ago) }
  scope :recently_installed, ->(days = 7) { where("installed_at > ?", days.days.ago) }
  scope :uninstalled, -> { where(status: "uninstalled") }
  
  # Instance methods
  def uninstall!
    update!(
      status: "uninstalled",
      uninstalled_at: Time.current
    )
  end
  
  def reactivate!(new_tokens)
    update!(
      status: "active",
      access_token: new_tokens["access_token"],
      refresh_token: new_tokens["refresh_token"],
      expires_at: Time.at(new_tokens["expires_at"]),
      last_used_at: Time.current,
      uninstalled_at: nil
    )
  end
  
  def expired?
    expires_at < Time.current
  end
  
  def expiring_soon?(buffer = 30.minutes)
    expires_at < buffer.from_now
  end
  
  def active?
    status == "active" && !expired?
  end
  
  def touch_last_used!
    touch(:last_used_at)
  end
  
  def to_token_hash
    {
      "nation_slug" => nation_slug,
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "expires_at" => expires_at.to_i,
      "token_type" => token_type,
      "scope" => scope,
      "installed_at" => installed_at.to_i,
      "last_used_at" => last_used_at.to_i
    }
  end
end
