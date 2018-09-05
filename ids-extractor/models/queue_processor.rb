require 'bunny'
require 'base64'
require 'pry'
require 'json'



#module IDSReader
  class QueueProcessor
    def initialize(reader)
			@config = Config.current
			@reader = reader

			@inbound_queue =  @config.in_queue
			@queue = @inbound_queue.queue


			@next_queue = @config.out_queue
	    @working_path = './tmp'
			#@document_processor = reader.processor
     #  @extract = extract
     #  @mode = @config.mode
     #  @tmp_path = extract.configuration.tmp_path + "p_#{Process.pid.to_s}/"
     #  puts "@@Tmp_path: #{@tmp_path}"
     #  @output_path = extract.configuration.output_path
     #  @pending_path = extract.configuration.pending_path
     #  puts "@@ QueueName: #{extract.configuration.queue_name}"
     #  @working_path = ENV['IDS_PATH'] + "extractors/working/#{extract.configuration.queue_name}/p_#{Process.pid.to_s}/"
     #  puts "@@ Working Path: #{@working_path}"
     #  FileUtils.mkdir_p @working_path
     #  @document_processor = @extract.processor
     #  queue_name = 'sharp_smh_rad' #@extract.configuration.queue_name
     #  puts "@@@Using queue: #{queue_name}"
     #  #puts "amqp: #{'IDSAMQP' + "_#{@mode.upcase}"}"
     #  rabbit = ENV['IDSAMQP' + "_#{@mode.upcase}"]
     #  puts "@@@Using AMQP: #{rabbit}"
     #  if rabbit.blank?  # use local RabbitMq Server
     #    rabbit = nil
     #  end
     #  puts "    @@@Using AMQP: #{rabbit}"
     #  @conn = Bunny.new(rabbit)
     #  @conn.start
     #  @storage_queue = StorageQueue.new(@conn, @mode)
     #
     #  #@unknown_queue = UnknownQueue.new(@conn, extract.configuration.queue_name, @mode)
     #
     #  #key = "#{queue_name}"
     #  @ch = @conn.create_channel
     #  #q = @ch.queue(queue_name)
     #  #x = @ch.topic('ids.reader')
     #  puts "  @@ Using queue name: #{queue_name}"
     # # @queue = @ch.queue(queue_name, exclusive: false, :auto_delete => false, :durable => true)
     #  @queue = @ch.queue(queue_name, :durable => true, exclusive: false, :auto_delete => false)
     #  #@queue = @ch.queue(queue_name,  exclusive: false, :auto_delete => false)
     #  #@queue.bind(x, routing_key: key)
     #  #puts "QueueProcessor started on queue (#{queue_name})"
    end

    def working_path
      @working_path
    end

    def process_queue
		begin
			$log.info "[x] version #{VERSION} Waiting for #{@queue.name} job on #{$amqp_connection_name}"
			@queue.subscribe(:manual_ack => true,:block => true) do |delivery_info, properties, body|
				@queue_data = JSON.parse(body)
				case @queue_data['command']
				when 'reset'
					process_reset
          @inbound_queue.ack(delivery_info.delivery_tag)
        when 'shutdown'
          puts "Shutdown in_queue"
          @in_queue.ack(@delivery_info.delivery_tag)
          @in_queue.close
          exit(0)  
				end
				@job_id = @queue_data['job_id']
				@source = @queue_data['source']
				@received_date = @queue_data['received_date']
				$log.info "        $$$$ working on job #{@job_id}"
				$log.debug "             Received Data: #{@received_date}"
				if @queue_data['image']
					image = Base64.decode64(@queue_data['image'])
				else
					image = File.open(@queue_data['file_name']).read
				end
				start_time = Time.now
				result = process_document(image)
				$log.debug "Job ID: #{@job_id} took #{(Time.now - start_time).in_milliseconds}ms"


				@inbound_queue.ack(delivery_info.delivery_tag)
				$log.info "       $$$$ #{VERSION} Finished Job: #{@job_id}"
				$log.info "[x] Version #{VERSION}  Waiting for job on #{@queue.name}"
			end
		rescue Interrupt => ex
		    $log.warn "   ProcessQueue interupt #{ex.inspect}"
			@inbound_queue.stop
			#@conn.close
		    abort "   ProcessQueue interupt #{ex.inspect}"
		rescue Exception => ex
			$log.warn "   ProcessQueue exception #{ex.inspect}"
			@inbound_queue.stop
			abort "   ProcessQueue exception #{ex.inspect}"
		end
    end

    def process_reset
	    $log.info('!!!   Process Reset')
		Config.active.reset_environment
    end

    def process_file(filename)
      image = File.open(filename).read
      process_document(image)
    end

    def process_document(image)
      @image_to_save = image

      if is_pdf(@image_to_save[0,10])
        $log.debug "   Process pdf"
        @data_type = :pdf
        @data = prepare_pdf
      elsif is_postscript(@image_to_save[0,10])
        $log.debug "   Process Postscript"
        @data_type = :pdf
        @data = prepare_postscript  #convert to pdf
      else
				$log.debug "Process straight text"
          @data_type = :text
          @data = @image_to_save
      end

      dp = @reader.processor
      $log.debug 'calling process_buffer'
     # dp = @document_processor.processor
      dp.process_buffer @data
      d = dp.document


      reports = d.reports
      unknowns = d.unknown_reports
      $log.warn "   found #{unknowns.count} unknown reports"
      $log.debug "   Found #{reports.count} valid reports"
      if(reports.count > 0)
        reports.each do |rep|
          # pdf/postscript file must be one report per file. Can not split 
          if(@data_type == :pdf)
            $log.debug"   Queue #{rep.report_type.class.name} as PDF to Storage process"
            $log.debug "     Data: #{rep.data}"
          elsif (@data_type == :ps)
            $log.debug "   Queue #{rep.report_type.class.name} as POSTSCRIPT to Storage process"
            $log.debug "     Data: #{rep.data}"
          else
            $log.debug "   Queue #{rep.report_type.class.name} as TEXT to Storage process"
            $log.debug "     Data: #{rep.data}"
      
          end
          rep.data['image_type'] = @data_type
          #rep.data['mode'] = @extract.configuration.mode
          rep.data['mode'] = @config.mode
          $log.debug "Found type: #{rep.data[:report_type]}"
          if rep.data['report_type'].nil?
	          rtype = rep.report_type.class.name.split('::')
	          if rtype.count > 1
							#puts "Count > 1 : #{rtype.count}"
		          rep.data['report_type'] = rtype[rtype.count - 1]
	          else
							#puts "Count 1 : #{rtype.count}"
		          rep.data['report_type'] = rtype[0]
	          end
          end


          #rep.data['report_type'] = rep.report_type.class.name
          rep.data['job_id'] = @job_id
          rep.data['source'] = @source
          rep.data['received_date'] = @received_date
          $log.debug "  ADDING received date: #{rep.data['received_date']}"
          #STDERR.puts "Storing in Archive\n\n"

          @next_queue.publish(rep.data, @image_to_save)
          #STDERR.puts "\n\n stored in archive"

        end
      end

      if unknowns.count > 0
        $log.warn "   processing #{unknowns.count} unknown reports"
        unknowns.each do |unk|
          if @data_type == :pdf
            image = @image_to_save
          else
            image = ""
            unk.pages.each do |p|
              p.lines.each do |l| 
                image += (l + "\n") 
              end
              image += "\f"
              $log.debug "TextFile"
            end
# leave as text so support can see the actual document
          end
#TODO Need to actually save the pdf here if not text Currently only one document in a pdf/ps "
          data = {}
          data['job_id'] = @job_id
          data['source'] = @source
          data['received_date'] = @received_date
          data['status'] = 'unknown'
    begin
          @next_queue.publish(data, image)
    rescue => ex
		$log.debug "Publish failed : #{ex.message}"
    end

          #File.open('./unknown', 'w') { |file| file.write(image) }
          #@unknown_queue.publish(image)
        end
      end
      $log.debug 'Done Processing going back for more.'
      #puts '\n\n\n'
    end

    def is_pdf(msg)
     # puts "is_pdf: #{msg}"
      reg = /PDF/
      reg =~ msg
    end

    def is_postscript(msg)
      #puts "is_postscript: #{msg}"
      reg = /PS-Adobe/
      reg =~ msg
    end

    def prepare_pdf
      puts "PreparePDF"
      msg = @image_to_save
      base_file = "#{@working_path}/#{SecureRandom.urlsafe_base64}"

      puts "BasePath = #{base_file}"
      pdf_file_name = "#{base_file}.pdf"
      STDERR.puts "PDFFile: #{pdf_file_name}"
      $log.debug "PDFFile = #{pdf_file_name}"
      #text_file_name = "#{base_file}.txt"
      out_path_name = @working_path
      pdf = File.open(pdf_file_name, 'w').write(msg)

      data = Pdf2Text.extract(pdf_file_name)

      #$log.debug "Extracted Data. Deleting #{pdf_file_name}"
      # Docsplit.extract_text pdf_file_name, :ocr => true, :output => out_path_name
      # data = File.open(text_file_name).read
      File.delete pdf_file_name
      #$log.debug "#{pdf_file_name} deleted"
      data
    end

    def prepare_postscript
      #puts "Prepare PostScript"
      msg = @image_to_save
      base_file = "#{@working_path}/#{SecureRandom.urlsafe_base64}"
      ps_file_name = "#{base_file}.ps"
      pdf_file_name = "#{base_file}.pdf"
      text_file_name = "#{base_file}.txt"
      out_path_name = @working_path
      ps = File.open(ps_file_name, 'w').write(msg)
      if(system 'ps2pdf', ps_file_name, pdf_file_name)
        x = Docsplit.extract_text pdf_file_name, :ocr => true, :output => out_path_name
        @image_to_save = File.open(pdf_file_name).read
        data = File.open(text_file_name).read
        File.delete pdf_file_name, ps_file_name, text_file_name
        data
      else
        nil
      end
    end
  end
#end