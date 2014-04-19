#!/usr/bin/ruby
require "httparty"
require "thread"

THREAD_COUNT = 30

mutex = Mutex.new
datas = File.open(ARGV[0], "r").read.split("\n")
dest_folder = (ARGV[1] ? ARGV[1] : "." ) + "/"
downloaded = []
THREAD_COUNT.times.map {
	Thread.new(datas) do |datas|
		while (file = mutex.synchronize {datas.pop})
			File.open(dest_folder + file.split("/").last, "wb") do |f| 
  				f.write HTTParty.get(file).parsed_response
			end
  			mutex.synchronize {downloaded << file}
  		end
  	end
}.each(&:join)
puts "Downloaded files :"
puts downloaded
if (datas.size > 0)
	puts "Not downloaded files :"
	puts datas
end
