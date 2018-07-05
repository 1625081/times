# !/usr/bin/python
# -*- coding:utf-8 -*-

import json
import os
import re

import xlrd


def Dict_Init():
    hash = []
    for i in range(0, 21):
        week = []
        week.append(i)
        week.append(0)
        hash.append(week)
    temp = dict(hash)
    return temp

# 懒得材料[1-6,13]这种情况，请自行解决或魔改课表


def Json_Generate(line_read):
    # line_read = input()
    line_total = line_read.split(']')
    line_total.pop()
    hash = ['0'] * 22
    for line in line_total:
        line = re.findall(r'[^\[\]]+', line)
        if(len(line) == 1):
            line = []
        else:
            line = line[1]
        if '-' in line:
            if "单" in line:
                line = line[:-1]
                a, b = (int(x) for x in line.split('-'))
                for i in range(a, b + 1):
                    if(i % 2 == 1):
                        hash[i] = '1'
            elif "双" in line:
                line = line[:-1]
                a, b = (int(x) for x in line.split('-'))
                for i in range(a, b + 1):
                    if(i % 2 == 0):
                        hash[i] = '1'
            else:
                a, b = (int(x) for x in line.split('-'))
                for i in range(a, b + 1):
                    hash[i] = '1'
        elif ',' in line:
            lis = (int(x) for x in re.split(r'[, ]', line))
            for i in lis:
                hash[i] = '1'
        elif line == []:
            for i in(1, 21):
                hash[i] = '1'
    j = "".join(hash)
    # print(j)
    return j


class LastCharacterError(Exception):
    def __init__(self):
        Exception.__init__(self)


# 请自行修改以下的path变量
path = "C:\\Users\\a1035\\Documents\\WeChat Files\\lpy18801339315\\Files\\2018春季课表-2018.3.14\\2018春季课表-2018.3.14\\"
# 复制文件所在地址，并使用\\代替\
try:
    dirs = os.listdir(path)
    if path[-1] != "\\" and path[-1] != "/":
        raise LastCharacterError
except FileNotFoundError:
    print("运行错误：请检查文件目录(path变量)是否正确！")
    exit(1)
except LastCharacterError:
    print("Windows系统下,目录必须以\\结尾;Unix下必须以/结尾")
    exit(1)

hash_total = []
for xls in dirs:
    try:
        data = xlrd.open_workbook(path + xls)
    except:
        print("运行错误：")
        print("1.请检查目录中文件是否都为xls格式")
        print("2.没有文件已在excel中打开")
        exit(1)

    table = data.sheets()[0]
    temp_build = []
    form = []
    for i in range(table.nrows):
        row = table.row_values(i)
        if i == 0:
            a = row[0].split("春季")[1]
            room_id = a.split("场地")[0]
            temp_build.append(room_id)
        elif i > 1 and i < 8:
            form.append(row)
    print(room_id, end=" ")
    temp_oneweek = []
    for i in range(2, 7):
        temp_oneday = []
        for j in range(0, 6):
            temp_one = []
            # 遍历同一列
            # if "王永革" in form[j][i] and "线性代数" in form[j][i]:
            # print(room_id)
            # print(form[j][i])
            x = "part" + str(j + 1)
            temp_one.append(x)
            temp_one.append(Json_Generate(form[j][i]))
            temp_oneday.append(temp_one)
        temp_oneday = dict(temp_oneday)
        temp_trans = []
        if i == 2:
            y = "Mon"
        elif i == 3:
            y = "Tues"
        elif i == 4:
            y = "Wed"
        elif i == 5:
            y = "Thur"
        elif i == 6:
            y = "Fir"
        x = y  # + str(i - 1)
        temp_trans.append(x)
        temp_trans.append(temp_oneday)
        temp_oneweek.append(temp_trans)
    temp_oneweek = dict(temp_oneweek)
    print(temp_oneweek)
    temp_build.append(temp_oneweek)
    hash_total.append(temp_build)
hash_total = dict(hash_total)
with open("test.json", "w", encoding='utf-8') as json_file:
    json.dump(hash_total, json_file, ensure_ascii=False)
'''
data = xlrd.open_workbook("j0-004.XLS")
table = data.sheets()[0]
nrows = table.nrows
ncols = table.ncols
for i in range(0, nrows):
    rowValue = table.row_values(i)
    for item in rowValue:
        print(item)
'''

'''
test = []
for i in range(1, 3):
    temp = []
    temp.append(i)
    temp.append(Json_Generate())
    test.append(temp)
test = dict(test)
print(test)
with open("test.json", "w", encoding='utf-8') as json_file:
    json.dump(test, json_file, ensure_ascii=False)
'''
