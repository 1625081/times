class Room < ApplicationRecord

  @@dict=Hash.new {'noinfo'}
  @@dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
  @@dict1={1=>"第一",2=>"第二",3=>"第三",4=>"第四",5=>"第五",6=>"第六"}
# 这是一种仅仅支持新建room的算法，不可以进行更新
#  def self.import(file)
#      CSV.foreach(file.path, headers: true) do |row|
#	      Room.create! row.to_hash
#	  end
#  end
#　J's code 1.0
  def self.import(file)
    hash=ActiveSupport::JSON.decode(File.read(file.open))
    hash.each { |classid,xingqi|
        help={}
        xingqi.each{ |xingqi,part|
          str=""
          part.each { |part,value|
            str=str+value.delete('\"')+','
          }
          str.chop!
          help[xingqi]=str
        }
        @room=Room.new
        @room.class_id=classid
        @room.mon=help["Mon"]
        @room.tue=help["Tues"]
        @room.wed=help["Wed"]
        @room.thr=help["Thur"]
        @room.fri=help["Fir"]
        @room.save!
    }
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
       return nil,key
     else
      return "now",key
     end
  end

  def match
    @first_week=9
    @week=Time.new.strftime('%U').to_i-@first_week
    @h=Time.new.hour
    @min=Time.new.min
    if @h<10
      @part=1#第一大节10.00
    elsif @h<12
      @part=2#第二大节12.00
    elsif @h<15||(@h==15&&@min<20)
      @part=3#第三大节15.20
    elsif @h<17||(@h==17&&@min<20)
      @part=4
    elsif @h<20
      @part=5
    else
      @part=6
    end
    des=""#装返回的描述信息
    str=eval("self."+@@dict[Time.new.wday])
    str1=str.split(',')
    while @part<=6
      if str1[@part-1][@week]=='0'
        des+=@@dict1[@part]
        @part+=1
      else
        break
      end
    end
      des+="大节空闲"
    return des
  end

  def self.resort(rooms)#按照时间点和教室id排序，满足空闲度高的教室优先,rooms里面是模型的每一个实例
    #要计算出当前的周数
    @first_week=9
    @week=Time.new.strftime('%U').to_i-@first_week
    @h=Time.new.hour
    @min=Time.new.min
    @day=Time.new.wday#表示星期,0是星期天
    if @h<10
      @part=1#第一大节10.00
    elsif @h<12
      @part=2#第二大节12.00
    elsif @h<15||(@h==15 && @min<20)
      @part=3#第三大节15.20
    elsif @h<17||(@h==17 && @min<20)
      @part=4
    elsif @h<20
      @part=5
    else
      @part=6
    end
    @dict2={}
    @dict2[0]=[]#表示仅当前课有空
    @dict2[1]=[]#后面1节有空
    @dict2[2]=[]
    @dict2[3]=[]
    @dict2[4]=[]
    @dict2[5]=[]
    rooms.each do |r|
      str=eval("r."+@@dict[@day])
      str1=str.split(',')
      if str1[@part-1][@week] == '0'#当前大节为空教室
        i=0
        while @part+i<=5 and str1[@part+i][@week]=='0'#数数，一共有多少的空节，来决定优先度
            i+=1
        end
        @dict2[i]<<r
      end
    end
    return @dict2[5]+@dict2[4]+@dict2[3]+@dict2[2]+@dict2[1]+@dict2[0]
  end
  def self.sort2(rooms)
    @room0=[]
    @room1=[]
    @room2=[]
    @room3=[]
    rooms.each do |r|
      if r.class_id.include? 'J3'
        @room0<<r
      elsif r.class_id.include? 'J4'
        @room1<<r
      elsif r.class_id.include? 'J5'
        @room2<<r
      else
        @room3<<r
      end
    end
    return @room0+@room1+@room2+@room3
  end
  def self.search(mode,key)
  	@rooms=[]
    @strs=[]
    # if (mode=~/周|星期/).is_a?(Fixnum)
      # @rooms,@strs=Room.predict(mode,key)
      # return @rooms,@strs
      Room.all.each do |r|
  		  if r.class_id.include? key
          @rooms<<r
  		  end
   	  end
    end
    @rooms=Room.resort(@rooms)#week代表当前的周数
    @rooms.each do |r|
      @strs<<r.match
    end
    return @rooms,@strs#rooms数组需要存放空闲的教室，strs数组存放对应教室的空闲课数
  end
