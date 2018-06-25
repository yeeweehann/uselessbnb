class Reservation < ApplicationRecord
  	belongs_to :user
  	belongs_to :listing
    validates_presence_of :start_date, :end_date
    validate :check_overlapping_dates, if: :check_error
    
    def check_error
        self.errors.blank?
    end 
    
    def check_overlapping_dates
    	dates = []
    	listing.reservations.each do |x|
    		dates += (x.start_date.to_date...x.end_date.to_date).to_a
    	end
    	if (dates & (self.start_date.to_date...self.end_date.to_date).to_a).count != 0
			errors.add(:overlapping_dates, "the reservation dates conflict")
   		end
    end

end
