
require 'pdf/reader'

#module IDSReader
	class Pdf2Text
		def self.extract(filename)
			@txt
			PDF::Reader.open(filename) do |reader|
				#puts "Extracting Text from #{filename}"
				pageno = 0
				txt = reader.pages.map do |page|

					pageno += 1
					begin
						#print "Extracting Page #{pageno}/#{reader.page_count}\r"
						page.text
					rescue
						$log.fatal "   !!! Page #{pageno}/#{reader.page_count} Failed to extract"
						return ''
					end
				end  # end of page map
				$log.info "   Extracted #{reader.page_count} pages"
				@txt = txt.join("\f")

			end  # End of reader open
			#$log.debug "Returning the extracted data"

			#puts "returning: #{@txt}"
			@txt
		end
	end
#end