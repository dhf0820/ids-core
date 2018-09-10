
require '../sys_models/delivery_class'
require '../sys_models/ids_error'
require '../sys_models/chart_archive_delivery'

class ChartArchiveClass < DeliveryClass
  @@cac = nil
  @@cad = nil

  def initialize
    @@cac = ChartArchiveClass.first
    if @@cac
      raise IdsError.new("ChartArchive is already setup")
    end
    super

    self.name = 'ChartArchive'
    self.description = 'Delivery to ChartArchive'
    @@cac =  self
  end

	def extend()
		#puts "Extend ChartArchiveClass:"
		self.name = 'ChartArchive'
		self.description = 'Delivery to ChartArchive'
		self.status = {}
		self.status[:state] = "Active"
		self.status[:reason] = "Initial System"
		self.write_attribute(:mail,  {} )   #what delivery for Mail require.

#TODO Set printer information
		# self.delivery_details[:printer_name] = ""
		# self.delivery_details[:printer_uri] = ''
		self.save
		cad = ChartArchiveDelivery.first
		if cad.nil?
			cad = ChartArchiveDelivery.new
		else
			puts "   ###$$$ MailDelivery already exists: #{md.inspect}"
		end

    cad.name = "ChartArchive"
    cad.description = "Delivery to ChartArchive"
		cad.delivery_class_id = self.id
		cad.delivery_class_name = self.name
		cad.save
		self.add_device(cad)
	end

  def device
    binding.pry
    if @@cad.nil?
      @@cad = ChartArchiveDelevery.first
    end

    @@cad
  end
  
  def self.default
    Config.active.chart_archive_class


    # #if @@cac.nil?
    #   @@cac = ChartArchiveClass.first
    #   if @@cac.nil?
    #     @@cac = ChartArchiveClass.new
    #     @@cac.save
    #     @@cad = ChartArchiveDelivery.first
    #     # @@cad = ChartArchiveDelivery.new
    #     # @@ca.a
    #     # @@cad.save
    #   end
    # #end
    # binding.pry
    # @@cac
  end


  def self.default_device
    self.default
    if @@cad.nil?
      puts "Creating delivery device"
			@@cad = ChartArchiveDelivery.first 
		end
		@@cad
  end
  
  def device
    ChartArchiveDelivery.first
  end


  def self.device
		self.default
		ChartArchiveDelivery.default
  end
  
  def queue(clin_doc, recipient, device)
		delv_req = DeliveryRequest.new
		delv_req.device = self.summary
		delv_req.device_id = device.id.to_s
		delv_req.device_class_id = self.id
		delv_req.recipient = recipient
		delv_req.patient = clin_doc.patient
		delv_req.document = clin_doc.summary
		delv_req.queued_time = DateTime.now
		delv_req.save
		delv_req
  end
  

end
