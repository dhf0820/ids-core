
require '../sys_models/delivery_class'
require '../sys_models/ids_error'
require './models/chart_archive_delivery'

class ChartArchiveClass < DeliveryClass
  @@ca = nil
  @@cad = nil

  def initialize
    @@ca = ChartArchiveClass.first
    if @@ca
      raise IdsError.new("ChartArchive is already setup")
    end
    super

    self.name = 'ChartArchive'
    self.description = 'Delivery to ChartArchive'
    @@ca =  self
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

  def self.default
    return @@ca if @@ca
    @@ca = ChartArchiveClass.first
    if @@ca.nil?
      @@ca = ChartArchiveClass.new
      @@ca.save
      @@cad = ChartArchiveDelivery.first
      # @@cad = ChartArchiveDelivery.new
      # @@ca.a
      # @@cad.save
    end
    @@ca
  end


  def self.default_device
		self.default
    if @@cad.nil?
      puts "Creating delivery device"
			@@cad = ChartArchiveDelivery.first 
		end
		@@cad
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
