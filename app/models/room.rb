class Room < ApplicationRecord

# 这是一种仅仅支持新建room的算法，不可以进行更新
#  def self.import(file)
#      CSV.foreach(file.path, headers: true) do |row|
#	      Room.create! row.to_hash
#	  end
#  end

#　本方法支持对有错误信息的room进行更新（通过新的CSV数据表）
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      room = find_by_id(row["id"]) || new
      room.attributes = row.to_hash.slice(*row.to_hash.keys)
      room.save!
    end
  end

# 用来确保一个教室在数据库唯一的方法
  def self.check()
    for room in Room.all
      if Room.where("class_id=?",room.class_id).size>1
        room.delete
      end
    end
  end

#进行关键字检查并且返回检索的教室信息
  def self.keycheck(key)
    # if (key=~/星期|周/).is_a?(Fixnum)
      # infos=key.split(" ")
      # for info in infos
        # if (info=~/星期|周/).nil?
          # key2=info
        # else
          # key1=info
        # end
      # end
      # key2||=""
      # return key1,key2
    if [6,0].include? Time.new.wday
      return nil,nil
    else
      return "now",key
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
    if eval('self.'+dict[Time.new.wday]).nil?
      return "全天空闲"
    elsif ((eval('self.'+dict[Time.new.wday]))=~/["#{str}"]/).nil?
      return dict2["#{str}"]+"空闲"
    elsif eval('self.'+dict[Time.new.wday]).include? str
      return dict2["#{str}"]+"满课"
    elsif eval('self.'+dict[Time.new.wday]).include? str[0]
      return "第"+str[1]+"节空闲"
    elsif eval('self.'+dict[Time.new.wday]).include? str[1]
      return "第"+str[0]+"节空闲"
    end

  end

  def self.resort(rooms)#按照时间点和教室id排序
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
    h=Time.new.hour
    if h<12
      str="12"#早上
    elsif h<18
      str="34"#下午
    else
      str="56"#晚上
    end
    @room0=[]#接受全天空闲教室
    @room1=[]#接受时间段内全空闲教室
    @room2=[]#有空闲教室
    @room3=[]#无空闲教室
    rooms.each do |r|
      if eval('r.'+dict[Time.new.wday]).nil?
        @room0<<r#上述代码周六日测试时会有bug
      elsif ((eval('r.'+dict[Time.new.wday]))=~/["#{str}"]/).nil?
        @room1=@room1<<r
      elsif eval('r.'+dict[Time.new.wday]).include? str
        @room3=@room3<<r
      else
        @room2<<r
      end
    end
    @room0.sort_by!{|e| e.class_id}
    @room1.sort_by!{|e| e.class_id}
    @room2.sort_by!{|e| e.class_id}
    @room3.sort_by!{|e| e.class_id}
    return @room0+@room1+@room2+@room3
  end

  def self.search(mode,key)
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
  	@rooms=[]
    @strs=[]
    # if (mode=~/周|星期/).is_a?(Fixnum)
      # @rooms,@strs=Room.predict(mode,key)
      # return @rooms,@strs
    if mode=="now"
      Room.all.each do |r|
  		  if (r.class_id.include? key)
          @rooms<<r
  		  end
   	  end
    end
    @rooms=Room.resort(@rooms)
    @rooms.each do |r|
      @strs<<r.match
    end
    return @rooms,@strs
  end

end
