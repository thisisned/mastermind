class Player # Generates / collects codes and guesses. Keeps track of guesses made.
	
	attr_accessor :guess_history, :feedback_history
	attr_reader :ai

	def initialize ai  
		@ai = ai
		@guess_history = []
		@feedback_history = []
	end

	def get_code
		if @ai # Probably there's a cleaner way to implement this. If player's a computer, gets a random quartet.
			code = []
			puts "Computer generating code. Press ENTER to continue."
			gets
			4.times { code << [1,2,3,4,5,6].sample }
			return code.join
		else
			print "Enter code: "
			loop do # Input checking for human code-getting
				code = gets.chomp
				if wrong_size? (code)
					puts "Must be four numbers long:"
				elsif wrong_range? (code)
					puts "Only numbers between 1 and 6:"
				else return code
				end
			end
		end
	end

	def wrong_size? code
		code.length != 4
	end

	def wrong_range? code
		code.split('').any? { |n| !n.to_i.between?(1, 6) }
	end

end

class Game

	def initialize
		@guesses_left = 12
		setup
	end
	
	def setup
		prompt = "> "
		puts "\nInstructions: Someone picks a code of 4 numbers between 1 and 6. Other guy tries to guess it."
		puts "Feedback is provided on how good your guesses are."
		puts "\nOptions:"
		puts "(1) Computer sets number, human guesses"
		puts "(2) Human sets number, computer guesses (badly)"
		puts "\n"
		print prompt
		while choice = gets.chomp.to_i
			case choice # True = AI, False = Person.
			when 1
				s, g  = true, false
				break
			when 2
				s, g = false, true
				break
			when 3
				s, g = false, false # Exciting hidden option! No AI, for debugging
				break
			else
				puts "1 or 2 please."
				print prompt
			end
		end
		@setter = Player.new(s)
		@guesser = Player.new(g)
		play
	end
	
	def play # Game logic / flow
		@master = @setter.get_code # Sets the master code to get guessed
		@guesses_left.downto(1) do |i|
			puts "Guesses left: #{i}.\n"
			guess = @guesser.get_code
			@guesser.guess_history << guess # Keeping track of guesses / feedback to draw the 'board'
			feedback = check(guess)
			@guesser.feedback_history << feedback
			draw
			if win(feedback)
				puts "YOU WIN HOORAY"
				break
			end
			if i == 1
				puts "Sorry you did not win booooo."
				break
			end
		end
		setup if play_again?
		exit
	end
	
	def check guess
	# A difficult to get head around method to check guess and generate feedback
	# - For each digit in the master code, goes through and checks if the corresponding digit in the guess is
	#   totally correct. Pushes an O to the feedback array if so and removes both.
	# - Then, checks each remaining number in the guess against what's left in the master code.
	#   Pushes an o to the feedback if included in master code, then element removed from master code.
		temp_master = @master.split('')
		temp_guess = guess.split('')
		feedback = []
		temp_master.each_with_index do |n, i|
			if n == temp_guess[i]
				feedback << "O"
				temp_guess[i] = "?"  # Maintaining length of arrays but replacing items with gibberish so
				temp_master[i] = "!" # they don't get counted twice.
			end
		end
		temp_guess.each do |n|
			if temp_master.include? n
				feedback << "o" 
				temp_master.delete_at(temp_master.index(n) || temp_master.length) # Deletes only first instance of n - handy
			end
		end
		feedback.sort.join # O's first, then o's
	end
	
	def win feedback
		feedback == "OOOO"
	end
	
	def play_again?
		puts "\nAnother game? (y/n)"
		print "> "
		gets.chomp.upcase == "Y" ? true : false
	end
	
	def draw # Draws a display with history of guesses and feedback (all formatted nice)
		puts "-"*21
		@guesser.guess_history.each_with_index do |n, i|
			puts "| %-3s | %-4s | %-4s |" % [(i+1).to_s+".", @guesser.guess_history[i], @guesser.feedback_history[i]]
		end
		puts "-"*21
		puts "\n(O = Correct number, correct location : o = Correct number, wrong location)\n\n"
	end

end

Game.new.play