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

  def self.predict(key)#预测教室情况包括：星期几和教室范围
    dict3={"一"=>"mon","二"=>"tue","三"=>"wed","四"=>"thr","五"=>"fri"}
    if (key=~/[一二三四五]/).nil?
      return nil
    else
      #这里的key2是一个包括教室范围的因子
      keyarr=key.split(" ")
      for keyword in keyarr
        unless keyword.include? "星期"
          key2=keyword
        end
      end
      hashes={}
      @rooms=[]
      @strs=[]
      if key2.nil?
        key2=""
      end
      Room.all.each do |r|
        if r.class_id.include? key2
          target=eval('r.'+dict3[key[key=~/["一二三四五"]/]])
          if target.nil?
            target=[""]
          else
            target=target.split("")
          end
          #求出r.xxx关键字符串单个字母所组成的数组
          array=["1","2","3","4","5","6"]
          for letter in target
            if letter!=""
              array.delete(letter)
            end
          end
          str=""
          for a in array
            str<<a<<'、'
          end
          str.chop!
          hashes.merge!({r=>str})
          #这里构造出来一个{房间=>描述空房间情况}的hash
        end
      end
      hashes=hashes.sort_by do |k,v|#k是教室,v是空闲节数
        v.length
      end
      for hash in hashes
        @rooms<<hash[0]
        if hash[1]==""
          @strs<<"全天满课"
        elsif hash[1]=="1、2、3、4、5、6"
          @strs<<"全天空闲"
        else
          str='第'<<hash[1]<<'节空闲'
          @strs<<str
        end
      end
      @strs.reverse!
      return @rooms,@strs
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

  def self.search(key)
    dict=Hash.new {'noinfo'}
    dict={1=>"mon",2=>"tue",3=>"wed",4=>"thr",5=>"fri"}
  	@rooms=[]
    @strs=[]
    if key.include? "星期"
      @rooms,@strs=Room.predict(key)
      return @rooms,@strs
    elsif ["6","0"].include? Time.new.wday
      redirect_to root_path
    else
      Room.all.each do |r|
  		  if (r.class_id.include? key)
          @rooms=@rooms<<r
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
