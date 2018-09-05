module IDSReader
	class Environment < ActiveRecord::Base

		@envs = {}

		def self.for_process(name)
			Environment.where(:process => name).first
		end

		def env(name)
			envs
			@envs[name]
		end

		def envs
			if self.environment.nil?
				@envs = {}
			else
				@envs = JSON.parse(self.environment)
			end

		end

		def add(name, value)
			envs
			@envs[name]= value
			self.save
		end

		def save
			unless @envs.nil?
				self.environment = JSON.generate(@envs)
			end

			super
		end

		def remove (item)
			if self.environment.nil?
				@envs = {}
			else
				envs
		    @envs = @envs.tap { |c| c.delete(item) }
				self.save
			end
		end


	end
end
