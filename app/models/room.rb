class Room < ApplicationRecord

  def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
	      Room.create! row.to_hash
	  end
  end

  def today
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
    if eval('self.'+dict[Time.new.wday]).nil?
      return "全天空闲"
    else
      return self.match
    end
  end


  def match
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
    dict2={"12"=>"上午","34"=>"下午","56"=>"晚上"}
    h=Time.new.hour

    if h<12
      str="12"
      #早上
    elsif h<18
      str="34"
      #下午
    else
      str="56"
      #晚上
    end

    if ((eval('self.'+dict[Time.new.wday]))=~/["#{str}"]/).nil?
      return dict2["#{str}"]+"空闲"
    elsif eval('self.'+dict[Time.new.wday]).include? str
      return dict2["#{str}"]+"满课"
    elsif eval('self.'+dict[Time.new.wday]).include? str[0]
      return "第"+str[1]+"节空闲"
    elsif eval('self.'+dict[Time.new.wday]).include? str[1]
      return "第"+str[0]+"节空闲"
    end

  end

  def retime
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
    h=Time.new.hour

    if h<12
      str="12"
      #早上
    elsif h<18
      str="34"
      #下午
    else
      str="56"
      #晚上
    end

    if eval('self.'+dict[Time.new.wday])
      if ((eval('self.'+dict[Time.new.wday]))=~/["#{str}"]/).nil?
        return true
      else
        return false
      end
    else
        return true #nil按照true处理
    end

  end

  def self.search(key)
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
  	@rooms=[]
    Room.all.each do |r|
  		if (r.class_id.include? key)
        @rooms=@rooms<<r
  		end
   	end
    @rooms=@rooms.sort_by{|e| e.class_id}
    @rooms=@rooms.sort_by{|e| eval('e.'+dict[Time.new.wday]).to_i}
    return @rooms
  end

end
