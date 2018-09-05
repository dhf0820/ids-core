
FactoryBot.define do
  factory :phy_french, class: Physician do
    ref_physician_id { 'f12345' }
    hospital_id { '12345' }
    has_privledges { true }
    affiliated { false }
    #status 'active'
    after(:build) do |p|
	    p.name = {}
	    p.name[:first] = 'Donald'
	    p.name[:middle] = 'H.'
	    p.name[:last] = 'French'
	    p.full_name = "Donald French"
    end
  end

  factory :phy_enyedi, class: Physician do
	  ref_physician_id { 'f12345' }
	  hospital_id { '12345' }
	  has_privledges { true }
	  affiliated { false }
	  #status 'active'
	  after(:build) do |p|
		  p.name = {}
		  p.name[:first] = 'Theresa'
		  p.name[:last] = 'French'
		  p.name[:full_name] = "Theresa French"
	  end
  end

  factory :phy_default, class: Physician do
	  ref_physician_id { 'd12345' }
	  hospital_id { 'dh12345' }
	  has_privledges { true }
	  affiliated { false }
	  #status 'active'
	  after(:build) do |p|
		  p.name = {}
		  p.name[:first] = 'Default'
		  p.name[:middle] = 'Delivery'
		  p.name[:last] = 'Physician'
		  p.name[:full_name] = "Default Delivery"
	  end
  end

  factory :phy_none, class: Physician do
	  ref_physician_id { 'n12345' }
	  hospital_id { 'nh12345' }
	  has_privledges { true }
	  affiliated { false }
	 # status 'active'
	  after(:build) do |p|
		  p.name = {}
		  p.name[:first] = 'No'
		  p.name[:middle] = 'Delivery'
		  p.name[:last] = 'Physician'
		  p.name[:full_name] = "No Delivery Physician"
	  end
  end

end
