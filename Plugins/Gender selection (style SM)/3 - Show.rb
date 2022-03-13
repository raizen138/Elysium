module GenderPickSelection
	class Show

		def show
			create_scene
			loop do
				break if @exit
				# Update
				update_ingame
				update_scene
				set_input
				update_player
			end
		end

		def create_scene
			# Background
			create_sprite("bg", "BackgroundSelect", @viewport)
			# Bitmap
			@realquant.times { |i|
				create_sprite("player #{i}", @player[i], @viewport)
				@sprites["player #{i}"].z = 1
			}
		end

		#-------#
		# Input #
		#-------#
		def set_input
			if @bg == 1
				if pbConfirmMessage("Are you sure you want to choose this player?")
					set_player(@position)
					@exit = true
				else
					@bg = 0
					@refresh = true
				end
				return
			end
			@bg = 1 if checkInput(Input::USE)
			if checkInput(Input::UP)
				@position -= 1
				if @position < @startnum
					if (@startnum - 1) >= 0
						@startnum -= 1
						@position  = @startnum
					elsif (@startnum - 1) < 0
						@startnum = @player.size - @realquant
						@position = @startnum + @realquant - 1
					end
					@refresh = true
				end
			elsif checkInput(Input::DOWN)
				@position += 1
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 1) <= @player.size
						@startnum += 1
						@position  = @startnum + @realquant - 1
					elsif (limit + 1 + 1) > @player.size
						@startnum = 0
						@position = 0
					end
					@refresh = true
				end
			elsif checkInput(Input::LEFT)
				@position -= 2
				if @position < @startnum
					if (@startnum - 2) >= -1
						@startnum -= 2
						if @startnum < 0
							@startnum = 0 
							@position = @startnum
						end
					elsif (@startnum - 2) < -1
						@startnum = @player.size - @realquant
						@position = @startnum + @realquant - 1
					end
					@refresh = true
				end
			elsif checkInput(Input::RIGHT)
				@position += 2
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 2) <= @player.size + 1
						@startnum += 2
						@startnum  = @player.size - @realquant if @startnum + @realquant > @player.size
						@position  = @startnum + @realquant - 1 if @position >= @player.size
					elsif (limit + 1 + 2) > @player.size + 1
						@startnum = 0
						@position = 0
					end
					@refresh = true
				end

			end
		end

		#--------#
		# Update #
		#--------#
		def update_scene
			return if @oldbg == @bg
			file = 
				case @bg
				when 0 then "BackgroundSelect"
				when 1 then "Background"
				end
			set_sprite("bg", file)
			@oldbg = @bg
		end

		def update_player
			case @bg
			when 0
				@realquant.times { |i|
					set_visible_sprite("player #{i}", true)
					if @refresh
						player = update_bitmap
						set_sprite("player #{i}", player[i])
					end
					x = 63 + 114 * (i / 2)
					y = 69 + (i.even? ? 0 : 165)
					set_xy_sprite("player #{i}", x, y)
					@sprites["player #{i}"].opacity = (@startnum + i) == @position ? 255 : 150
				}
				@refresh = false if @refresh
			when 1
				@realquant.times { |i|
					if (@startnum + i) == @position
						set_xy_sprite("player #{i}", 206, 104)
						next
					end
					set_visible_sprite("player #{i}")
				}
			end
		end

		def update_bitmap
			player = []
			n = @startnum + @realquant
			(@startnum...n).each { |i| player << @player[i] }
			return player
		end

	end
end