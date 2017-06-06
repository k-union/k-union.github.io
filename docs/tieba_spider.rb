#!/usr/bin/env ruby
#encoding=UTF-8
require 'mechanize'
require 'json'
require 'yaml'
require 'nokogiri'
$header={
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Encoding"=>"deflate,sdch",
        "Accept-Language"=>"zh-CN,zh;q=0.8",
        "Connection"=>"keep-alive",
        "User-Agent"=>"Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
}
$agent = Mechanize.new
$agent.user_agent_alias = 'Windows Firefox'
def get index
        doc=$agent.get("http://tieba.baidu.com/f?kw=%E8%BD%AC%E5%9F%BA%E5%9B%A0&ie=utf-8&tab=good&cid=&pn=#{index*50}")
        flag=doc.at("//code[@id='pagelet_html_frs-list/pagelet/thread_list']/comment()")
        doc=Nokogiri::HTML.parse flag.text unless flag.nil?
        doc.xpath(".//li[contains(@class,'j_thread_list') and @data-field]").map do |li|
                data=JSON.load li["data-field"].gsub('&quot;','"')
                username=data["author_name"]
                kz=data["id"]
                top= data["is_top"]==1
                fine= data["is_good"]==1
                live= data["is_portal"]==1
                reply_num=data["reply_num"]
                /^\s*(.+?)\s*$/===li.at(".//div[contains(@class,'threadlist_title')]").text
                title=$1
                sn=li.at(".//div[contains(@class,'threadlist_abs')]")
                if sn and /^\s+(.+?)\s+$/===sn.text
                        summary=$1
                else
                        summary=""
                end
                {
                        :title => title,
                        :author => username,
                        :summary => summary,
                        :kz => kz,
                        :rpn => reply_num
                }
        end
end

File.write "zjy_threads.json", (0..850/50).map{|i|
        puts "GET PAGE #{i}"
        get(i)
}.flatten.to_json
