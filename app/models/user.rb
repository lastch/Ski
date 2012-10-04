class User < ActiveRecord::Base
  belongs_to :role
  belongs_to :billing_country, class_name: 'Country'
  belongs_to :coupon
  belongs_to :image

  has_many :directory_adverts, dependent: :destroy
  has_many :enquiries, dependent: :delete_all, order: "created_at DESC"
  has_many :adverts, dependent: :delete_all
  has_many :adverts_in_basket, class_name: 'Advert', conditions: {starts_at: nil}

  # TODO: these should probably exclude expired windows
  has_many :windows, class_name: 'Advert', conditions: {window: true}, order: "expires_at DESC"
  has_many :empty_windows, class_name: 'Advert', conditions: {property_id: nil, window: true}, order: "expires_at DESC"

  has_many :properties, dependent: :destroy
  has_many :properties_for_rent, class_name: 'Property', conditions: {listing_type: Property::LISTING_TYPE_FOR_RENT}
  has_many :properties_for_sale, class_name: 'Property', conditions: {listing_type: Property::LISTING_TYPE_FOR_SALE}
  has_many :hotels, class_name: 'Property', conditions: {listing_type: Property::LISTING_TYPE_HOTEL}
  has_many :images, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :orders_with_receipts, class_name: 'Order', conditions: "status NOT IN (#{Order::WAITING_FOR_PAYMENT})",
    order: 'created_at DESC'

  has_many :airport_transfers, dependent: :delete_all

  attr_protected :role_id
  attr_protected :coupon_id
  attr_protected :forgot_password_token
  attr_protected :image_id

  attr_accessor :password

  validates_length_of :password, within: 5..40, if: :password_required?
  validates_format_of :google_web_property_id, with: /\AUA-\d\d\d\d\d\d(\d)?(\d)?(\d)?-\d(\d)?\Z/, allow_blank: true

  validates_presence_of :first_name
  validates_presence_of :last_name

  validates_uniqueness_of :email
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_format_of :vat_number, with: /[a-z][a-z].*/i, allow_blank: true

  validates_presence_of :billing_street
  validates_presence_of :billing_city
  validates_presence_of :billing_country_id
  validates_presence_of :role_id

  validates_format_of :website, with: /^(#{URI::regexp(%w(http https))})$/, allow_blank: true

  validates_acceptance_of :terms_and_conditions, on: :create, accept: true

  before_save :encrypt_password

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{pass}--")
  end

  def self.authenticate(email, pass)
    user = find_by_email(email)
    user && user.authenticated?(pass) ? user : nil
  end

  def authenticated?(pass)
    encrypted_password == User.encrypt(pass, salt)
  end

  def self.generate_forgot_password_token
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z}
    (0...8).map{ charset.to_a[rand(charset.size)] }.join
  end

  def has_properties_for_rent?
    properties_for_rent.count > 0
  end

  def has_properties_for_sale?
    properties_for_sale.count > 0
  end

  def has_adverts_in_basket?
    adverts_in_basket.count > 0
  end

  def directory_advert_in_basket
    adverts_in_basket.each do |a|
      return a.directory_advert if a.directory_advert
    end
    nil
  end

  def banner_adverts_so_far
    Advert.count(
      conditions: ['user_id = ? AND directory_advert_id IS NOT NULL AND starts_at IS NOT NULL AND starts_at > DATE_SUB(NOW(), INTERVAL 365 DAY)',
      id])
  end

  def directory_adverts_so_far
    Advert.count(
      conditions: ['user_id = ? AND directory_advert_id IS NOT NULL AND starts_at IS NOT NULL AND starts_at > DATE_SUB(NOW(), INTERVAL 365 DAY)',
      id])
  end

  def property_adverts_so_far
    Advert.count(
      conditions: ['user_id = ? AND property_id IS NOT NULL AND starts_at IS NOT NULL AND starts_at > DATE_SUB(NOW(), INTERVAL 365 DAY)',
      id])
  end

  def adverts_so_far
    banner_adverts_so_far + directory_adverts_so_far + property_adverts_so_far
  end

  def basket_contains? advert_object
    adverts_in_basket.each do |a|
      return true if a.object == advert_object
    end
    false
  end

  # Returns true if the user should pay VAT.
  # A user pays VAT when their billing country is in the EU and they have not
  # supplied a VAT number.
  # All customers in the UK should pay VAT, regardless of a VAT number.
  #
  # :call-seq:
  #   pays_vat? -> true or false
  def pays_vat?
    (vat_number.blank? && billing_country.in_eu?) || billing_country.iso_3166_1_alpha_2 == 'GB'
  end

  def tax_description
    pays_vat? ? 'VAT' : 'Zero Rated'
  end

  def to_s
    name
  end

  def name
    "#{first_name} #{last_name}"
  end

  def airport_transfer_company?
    airport_transfer_banner_advert
  end

  def airport_transfer_banner_advert
    directory_adverts.each do |a|
      return a if a.is_banner_advert? && a.currently_advertised? && a.category.name == 'category_names.airport_transfer'
    end
    nil
  end

  protected

  def encrypt_password
    return if password.blank?
    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{email}--")
    end
    self.encrypted_password = User.encrypt(password, salt)
  end

  def password_required?
     encrypted_password.blank? || !password.blank?
   end
end
