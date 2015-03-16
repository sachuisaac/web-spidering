require 'rubygems'
require 'watir-webdriver'
#require 'tree'

$xmenulist = []
$number = 0
def returnListArray(catArray, file) 
	
	menulist = []
	str = String.new("")

	catArray.each do |cat|
		element = @browser.li(:id => cat)
		if element.a.exists?
			if element.a.attribute_value('class').match(/x-menu-item-arrow/)
				str = String.new("")
				$number.times { str<<"\t"}
				puts "#{str} #{element.text}"
				file.puts "#{str} #{element.text}"
				element.a.click
				sleep 1
				@browser.uls(:class => "x-menu-list").each do |ul|
					menulist << ul.id
				end
				$xmenulist = $xmenulist | menulist
				#puts "#{cat} : #{$xmenulist}"
				listMenu = []
				array = Array.new
				listMenu = @browser.ul(:id => $xmenulist.last)
				$number += 1
				listMenu.lis.each do |l|
					array << l.id
				end
				$number -=1
				if array.any?
					#puts "#{array}\n"
					$number += 1
					returnListArray(array, file)
					$number -= 1
					flag = 1
				end
			end
		end
		if element.div.exists?
			if element.div.attribute_value('class').match(/x-panel/)
				if element.div.div.exists?
					if element.div.div.attribute_value('class').match(/x-panel-bwrap/)
						str = String.new("")
						$number.times { str <<"\t"}
						print "#{str} #{element.text.strip}\t +/-"
						file.print "#{str} #{element.text.strip}\t +/-"
						
					elsif element.div.div.span.exists?
						str = String.new("")
						$number.times { str<<"\t"}
						puts "#{str} #{element.div.div.span.text}\t InputField"
						file.puts "#{str} #{element.div.div.span.text}\t InputField"
					end
				end
			elsif element.div.attribute_value('class').match(/x-date-picker/)
				str = String.new("")
				$number.times { str<<"\t"}
				puts "#{str} CalenderInput"
				file.puts "#{str} CalenderInput"
			end
		else
			if flag != 1
				str = String.new("")
				$number.times { str<<"\t"}
				puts "#{str} #{element.text}"
				file.puts "#{str} #{element.text}"
			end
		end
	end
end



@browser = Watir::Browser.new
@browser.goto 'https://ehr.kareo.com/EhrWebApp/login.html'
sleep 10
@browser.text_field(:name => 'userName').set ARGV[0]

@browser.text_field(:name => 'password').set ARGV[1]

@browser.button().click

@browser.goto 'https://ehr.kareo.com/EhrWebApp/patients/viewFacesheet/19436183'
@browser.goto 'https://ehr.kareo.com/EhrWebApp/../../patients/19436183/notes/new/'
@browser.link(:text => "Template").when_present.click
@browser.div(:id => 'ext-comp-1764').wait_until_present
(1..152).each do
	sleep 20
	myArray = []
	menu = Array.new
	@browser.uls(:class => "x-menu-list").each do |ul|
		menu << ul.id
	end
	#puts menu.last
	filename = String.new
	if @browser.ul(:id => menu.first).exists?
		list = @browser.ul(:id => menu.first)
		list.lis.each do |li|
			filename = li.text
			puts filename
			puts ""
			puts ""
			break
		end
	end
	filename += ".txt"
	file = File.open(filename, "w")
	puts "---------------------------------------------------------------------"
	file.puts "---------------------------------------------------------------------"
	if @browser.ul(:id => menu.last).exists?
		listMenu = @browser.ul(:id => menu.last)
		listMenu.lis.each do |li|
			myArray << li.id
			puts li.text
			file.puts li.text
		end
	end
	returnListArray(myArray, file)
	puts "---------------------------------------------------------------------"
	file.puts "---------------------------------------------------------------------"
	file.close
	exec("sed -i '/^$/d' "+filename)
end
