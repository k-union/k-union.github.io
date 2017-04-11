#!/usr/bin/env ruby
#encoding=utf-8
require 'json'
data = JSON.load File.read 'zjy_threads.json'
ad = data.group_by{|x| x['author']}
File.write 'authors.json', ad.map{|k, v| [k, v.count]}.sort_by{|k,v| v}.reverse.to_json
