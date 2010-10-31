#this is going to be the main commandline tool for xc
# it will have functions for creating new projects,
# running them, and other cool stuff.  Watch it go!
require 'sprockets'

run()

def run()
	project = ARGV[0]
	command = ARGV[1]
	if command == 'create'
		if project
			new_project(project)
		else
			puts 'You must provide a project name'
		end
	else
		puts 'unrecognized command ' + command
	end
end

def new_project(name)
	puts "Creating project " + name
end

def make_HTML()
	
	puts "This is gonna make a good HTML file"
	
	title = "XC Test"
		
	width = '320'
	height = '480'
	
	script = 'test.js'
	
	# lets get the images from the resources directory
	images = Dir['./resources/*'].find_all{|item| item =~ /.*\.png/}
	item_count = images.length.to_s()
	file_names = ''
	images.each {|image| fileNames += '<img src="' + image + '" onLoad="itemLoaded(this);"></img>'}

	
	#now read in the html tempate
	
	template = IO.read('../lib/htmltemplate')
	
	template['@TITLE'] = title
	template['@ITEMCOUNT'] = item_count
	template['@WIDTH'] = width
	template['@HEIGHT'] = height
	template['@SCRIPT'] = script
	template['@IMAGES'] = file_names
	
	index = File.new('./index.html', 'w')
	if index
		index.syswrite(template)
	else
		puts 'unable to open index.html'
	end
end
