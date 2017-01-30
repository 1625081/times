class Room < ApplicationRecord

  def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
	      Room.create! row.to_hash
	  end
  end

  def self.search(key)
  	@rooms=[]
  	Room.all.each do |r|
  		if r.class_id==key
  			@rooms=@rooms<<r
  		end
  	end
  	return @rooms
  end
  
end