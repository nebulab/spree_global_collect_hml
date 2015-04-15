Spree::Address.class_eval do
  def global_collect_firstname
    firstname.try(:truncate, 15)
  end

  def global_collect_surname
    lastname.try(:truncate, 15)
  end

  def global_collect_city
    city.try(:truncate, 40)
  end

  def global_collect_street
    "#{address1} #{address2}".truncate(50)
  end
end
