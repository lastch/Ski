require 'xmlsimple'

class AccommodationImporter
  attr_accessor :import_start_time, :user

  # Subclasses should implement the following methods:
  # * accommodation
  # * import_accommodation
  # * model_class
  # * user_email

  # Non-destructive import.
  # Updates existing accommodations and imports new accommodations
  # from the XML file.
  # Old accommodations are destroyed by checking their updated_at timestamps.
  def import(filenames, cleanup)
    setup
    filenames.each {|f| import_file(f)}
    if cleanup
      delete_old_adverts
      destroy_all
    end
  end

  def setup
    @user = User.find_by(email: user_email)
    raise "A user with email #{user_email} is required" unless @user

    @euro = Currency.find_by(code: 'EUR')
    raise 'A currency with code EUR is required' unless @euro

    @import_start_time = Time.now
  end

  # Imports a single XML file. Property geocoding is suspended for the
  # duration of the file's import.
  def import_file(filename)
    xml_file = File.open(filename, 'rb')
    xml = XmlSimple.xml_in(xml_file)
    xml_file.close

    Property.stop_geocoding
    accommodations(xml).each {|a| import_accommodation(a)} if xml
    Property.resume_geocoding
  end

  def create_advert(property)
    advert = Advert.new
    advert.user_id = @user.id
    advert.property_id = property.id
    advert.starts_at = Time.now
    advert.expires_at = Time.now + 10.years
    advert.months = 120
    advert.save
  end

  def delete_old_adverts
    Advert.delete_all(['user_id = ? AND updated_at < ?', @user.id, @import_start_time])
  end

  def destroy_all
    model_class.destroy_all(['updated_at < ?', @import_start_time])
  end

  def accommodation(xml)
    raise 'Subclass should return an array of all accommodation XML'
  end

  def import_accommodation(a)
    raise 'Subclass should import the data'
  end

  def model_class
    raise 'Subclass should return an ActiveRecord model subclass'
  end

  def user_email
    raise 'Subclass should return an email address for a user that will own the imported data'
  end
end
