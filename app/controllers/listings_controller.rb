class ListingsController < ApplicationController
	before_action :require_superadmin, only: [:verify, :destroy]
	before_action :require_moderator, only: []
	before_action :require_customer, only: []
	#before_action :require_moderator || :require_superadmin, only: [:edit, :update]
	#before_action :require_superadmin || :require_moderator || :require_customer, only: [:create, :new, :reserve, :your_listings]
	
	
	def create
		@new = current_user.listings.new(listing_params)
		if @new.save
			if current_user.customer?
				current_user.moderator!
			end
			redirect_to '/listings/tobeverified'
		end
    end 

    def tobeverified
    end

    def new
    	@user = current_user
    	@listing = Listing.new
    end

	def index
		@listing_count = Listing.where(verified: true).count
		@listings = Listing.page(params[:page]).per(10).where(verified: true)
	end

	def show
		@listing = Listing.find(params[:id])
	end

	def edit
		@listing = Listing.find(params[:id])
		@user = User.find(params[:user_id])
	end

	def update		
		@listing = Listing.find(params[:id])
		if @listing.update(listing_params)
			redirect_to listing_path, :flash => { :success => "Listing successfully updated" }
		else
			redirect_to edit_user_listing_path, :flash => { :error => "Failed to update" }
		end
	end

	def destroy
		@listing = Listing.find(params[:id])
	end

	def verify
		@listing = Listing.find(params[:id])
		@listing.update(verified: true)
		redirect_to listing_path(@listing)
	end

	def unverified
		@listing_count = Listing.where(verified: false).count
		@listings = Listing.page(params[:page]).per(10).where(verified: false)
	end

	def reserve
		@listing = Listing.find(params[:id])
	end

	def your_listings
		@listings = Listing.where(user_id: current_user.id)
		render "listings/your_listings"
	end

	private
	def listing_params
		params.require(:listing).permit(:location, :tags, :name, :place_type, :property_type, :room_number, :bed_number, :guest_number, :country, :state, :city, :zipcode, :price, :description, :listing_cover, {:image => []})
	end

	def require_superadmin
		unless current_user == Listing.find(params[:id]).user || current_user.superadmin?
			flash[:notice] = "Sorry. You are not allowed to perform this action."
        redirect_to 'listing_path(params[:id])', notice: "Sorry. You do not have the permission to perform this action."
		end
	end

	def require_moderator
		unless current_user == Listing.find(params[:id]).user || current_user.moderator?
			flash[:notice] = "Sorry. You are not allowed to perform this action."
        redirect_to 'listing_path(params[:id])', notice: "Sorry. You do not have the permission to perform this action."
		end
	end

	def require_customer
		unless current_user.customer?
			flash[:notice] = "Sorry. You are not allowed to perform this action."
        redirect_to '/sign_in', notice: "Please sign-in before performing this action."
		end
	end
end





