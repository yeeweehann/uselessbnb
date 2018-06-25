class WelcomeController < ApplicationController
	def index
		@listings = Listing.where(verified: true).sample(6)
	end
end
