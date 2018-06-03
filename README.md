# TIMES——测试中的课表查询系统

## 数据

### 数据处理

原数据是excel软件默认的xls/xlsx格式，这种格式并不能很好地兼容linux系统以及Python脚本的运作，于是这里我们用excel自带的VB宏批量地将xls类文件转化为csv格式的文件（具体方式是百度的），二者在excel中打开几乎看不出任何区别。

对于原数据使用如下的Python脚本可以进行初步处理

```python
import csv
import os

dirs=[]
files=[]
cu=os.getcwd()
dirs=os.listdir(cu)

#对文件夹下所有csv表格做处理
for f in dirs:
    if f[0]=='.' or f[0]=='_'or f[0]=='o':
        dirs.remove(f)
#开始把结果写入csv文件
with open('_slimresult.csv','a+') as csvfile:
    writer = csv.writer(csvfile,dialect='excel')
    writer.writerow(["class_id","mon","tue","wed","thr","fri"])

for table in dirs:
    form=[]
    with open(table, 'r+') as h:
        reader = csv.reader(h)
        f=True
        for row in reader:
            if f==True:
                a=row[0].split("秋季")[1]
                b=a.split("场地")
                #print(b[0])
                f=False
            else:
                form.append(row)
    column=[""]*5
    for i in range(2,7):
        for j in range(1,7):
            column[i-2]+=form[j][i]+'END'
    slimcolumn=[]
    for item in column:
        items=item.split("END")
        numstr=''
        for i in items:
            if i!='':numstr+=str(items.index(i)+1)#如果课位非空，就记录下这个时间段/课位
        slimcolumn.append(numstr)
    with open('_slimresult.csv','a+') as csvfile:
        writer = csv.writer(csvfile,dialect='excel')
        writer.writerow([b[0],slimcolumn[0],slimcolumn[1],slimcolumn[2],slimcolumn[3],slimcolumn[4]])
```

之后的数据格式应该是某些类似于这样的东西:

J3-XXX 1234 12 345 12 3456

这里，第一位表示教室编号，第二到六位表示的是有课的节数。众所周知，一天一共六节大课，上午两节，下午两节，晚上两节，数据中的数字就是从1-6代表这些大课。

### 数据导入

页面上的数据导入功能允许测试者上传一个修改后的CSV数据表，可以与原先相比新增、修改某些数据。

```ruby
def self.import(file)
  CSV.foreach(file.path, headers: true) do |row|
    room = find_by_id(row["id"]) || new
    room.attributes = row.to_hash.slice(*row.to_hash.keys)
    room.save!
  end
end
```

## 搜索

### 具体搜索算法

具体搜索算法这里就不详细地讲解了，大致讲解一下搜索思路。

* 即时搜索

这种模式是根据用户当时的时间，把用户分到一个区间里(例如：星期四 晚上)，先根据关键词(key)进行初步筛选，之后会优先选择星期四晚上的空教室放在最前面，晚上有课/满课的教室排在后面/最后面。例如: 我在星期四的晚上搜索""(key为空字符串)，则会返回所有教室在周四晚按照空闲程度从高到低的排序。如果我搜索"J3"(key为"J3")，则会返回J3教室在周四晚按照空闲程度从高到低的排序。

* 预测搜索

这种模式是用户想要预测某一天的空教室情况时使用的。用户需要输入两个关键词"星期X＋key"，第一个参数确定了哪一天，第二个参数确定关键词。排序方法同上。例如：我输入"星期一"，则会返回周一教室的使用情况；输入"星期一 J3-101"　则会返回"J3-101"教室在星期一的使用情况。

* 对key的说明

没什么好说的，搜索方法并不高级，key其实就是class_id(JX-XXX)的一部分，随便输的话可能没有匹配结果(

这就是目前的全部了，代码实现如果有时间我会补上～

开发者——ZSJ
