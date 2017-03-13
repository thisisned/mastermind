class Player
	
	attr_accessor :guess_history, :feedback_history
	attr_reader :ai

	def initialize (ai)
		@ai = ai
		@guess_history = []
		@feedback_history = []
	end

	def get_code
		if @ai
			code = []
			puts "Computer generating code. Press ENTER to continue."
			gets
			4.times { code << [1,2,3,4,5,6].sample }
			return code.join
		else
			print "Enter code: "
			loop do
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

	def wrong_size? (code)
		code.length != 4
	end

	def wrong_range? (code)
		code.split('').any? {|n| !n.to_i.between?(1, 6) }
	end

end

class Game

	def initialize
		@guesses_left = 12
		setup
	end
	
	def setup
		prompt = "> "
		puts "Options:"
		puts "(1) Computer sets number, human guesses"
		puts "(2) Human sets number, computer guesses (badly)"
		puts "\n"
		print prompt
		while choice = gets.chomp.to_i
			case choice
			when 1
				s, g  = true, false
				break
			when 2
				s, g = false, true
				break
			when 3
				s, g = false, false # No AI, for debugging
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
	
	def play
		@master = @setter.get_code
		@guesses_left.downto(1) do |i|
			puts "Guesses left: #{i}.\n"
			guess = @guesser.get_code
			@guesser.guess_history << guess
			feedback = check(guess)
			@guesser.feedback_history << feedback
			draw
			if win(feedback)
				puts "YOU WIN HOORAY"
				setup if play_again?
				exit
			end
			if i == 1
				puts "Sorry you did not win booooo."
				setup if play_again?
				exit
			end
		end
	end
	
	def check(guess)
		temp_master = @master.split('')
		temp_guess = guess.split('')
		feedback = []
		temp_master.each_with_index do |n, i|
			if n == temp_guess[i]
				feedback << "O"
				temp_guess[i] = "?"
				temp_master[i] = "!"
			end
		end
		temp_guess.each do |n|
			if temp_master.include? n
				feedback << "o" 
				temp_master.delete_at(temp_master.index(n) || temp_master.length)
			end
		end
		feedback.sort.join
	end
	
	def win(feedback)
		feedback == "OOOO"
	end
	
	def play_again?
		puts "\nAnother game? (y/n)"
		print "> "
		gets.chomp.upcase == "Y" ? true : false
	end
	
	def draw
		puts "-"*21
		@guesser.guess_history.each_with_index do |n, i|
			puts "| %-3s | %-4s | %-4s |" % [(i+1).to_s+".", @guesser.guess_history[i], @guesser.feedback_history[i]]
		end
		puts "-"*21
		puts "\n(O = Correct number, correct location : o = Correct number, wrong location)\n\n"
	end

end

Game.new.play