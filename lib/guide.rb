require 'restaurant'
require 'support/string_extend'
class Guide

	class Config
		@@actions =['list', 'find', 'add', 'quit']
		def self.actions; @@actions; end
	end

	def initialize(path=nil)
		# locate the restaurant text file at path
		Restaurant.filepath = path
		if Restaurant.file_usable?
			puts "Restaurant file found"
		# or create a new file
		elsif Restaurant.create_file
			puts "Created restaurant file"
		# exit if create fails
		else
			puts "Exiting.\n\n"
			exit!
		end
	end

	def launch!
		introduction
		# action loop
		result = nil
		until result == :quit
			action, args = get_action
			result = do_action(action, args)
			# repeat until user quits
		end
		conclusion
	end

	def get_action
		action = nil
		# Keep asking for user input until we get a valid action
		until Guide::Config.actions.include?(action)
			puts "Mogelijke commando's : " + Guide::Config.actions.join(", ")
			print "> "
			user_response = gets.chomp
			args = user_response.downcase.strip.split(' ')
			action = args.shift
		end
		return action, args
	end

	def do_action(action, args=[])
		case action
		when 'list'
			list(args)
		when 'find'
			keyword = args.shift
			find(keyword)
		when 'add'
			add
		when 'quit'
			return :quit
		else
			puts "\nDit commando is onbekend.\n"
		end
	end

	def list(args=[])
		sort_order = args.shift
		sort_order = args.shift if sort_order == "by"
		sort_order = "name" unless ['name', 'cuisine', 'price'].include?(sort_order) 
		
		output_action_header("Maak een lijst van de restaurants")

		restaurants = Restaurant.saved_restaurants
		restaurants.sort! do  |r1, r2|
			case sort_order
			when 'name'
				r1.name.downcase <=> r2.name.downcase
			when 'cuisine'
				r1.cuisine.downcase <=> r2.cuisine.downcase
			when 'price'
				r1.price.to_i <=> r2.price.to_i
			end
		end
		output_restaurant_table(restaurants)
		puts "U kunt de lijst sorteren met bv.: 'list cuisine' of 'list by cuisine'"
	end

	def find(keyword="")
		output_action_header("Vind een restaurant")
		if keyword
			restaurants = Restaurant.saved_restaurants
			found = restaurants.select do |rest|
				rest.name.downcase.include?(keyword.downcase) ||
				rest.cuisine.downcase.include?(keyword.downcase) ||
				rest.price.to_i <= keyword.to_i
			end
			output_restaurant_table(found)
		else
			puts "Zoek naar woorden in de Restaurant Gids"
			puts "Bijv. 'find mexican'\n\n"
		end
	end

	def add
		output_action_header("Voeg een restaurant toe")
		restaurant = Restaurant.build_from_questions
		if restaurant.save
			puts "Restaurant toegevoegd"
		else
			puts "Foutmelding, restaurant niet opgeslagen"
		end 
	end


	def introduction
		puts "\n\n< Welkom in de Restaurant Gids >\n\n"
		puts "Deze interactieve gids helpt je bij het vinden van de juiste maaltijd.\n\n"
	end

	def conclusion
		puts "\n< Eet smakelijk en tot ziens! >\n\n"
	end

	private

	def output_action_header(text)
		puts "\n#{text.upcase.center(60)}\n\n"
	end

	def output_restaurant_table(restaurants=[])
	    print " " + "Name".ljust(30)
	    print " " + "Cuisine".ljust(20)
	    print " " + "Price".rjust(6) + "\n"
	    puts "-" * 60
	    restaurants.each do |rest|
		    line =  " " << rest.name.titleize.ljust(30)
		    line << " " + rest.cuisine.titleize.ljust(20)
		    line << " " + rest.formatted_price.rjust(6)
		    puts line
    end
    puts "No listings found" if restaurants.empty?
    puts "-" * 60
  end


end