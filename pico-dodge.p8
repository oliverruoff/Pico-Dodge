pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- pico-dodge
-- by oliver ruoff

floor_y = 85
gravity = 0.2
anim_cnt = 0
block_gen_prob = 2 // in %
score = 0
game_over = false
paused = false
birds_gen_prob = 3
clouds_gen_prob = 1

function _init()
  -- preparing save state
  cartdata(
    "vanslipon_pico-dodge_1")
  -- loading highscore
  loadhighscore()
  -- set player on floor
  plr.y = floor_y-plr.hght
end

function _update()
		-- 🅾️ pressed pressed
		if btn(🅾️) then
		  -- if currently gameover
		  -- resetting the game
				if game_over then
				  game_over = false
				  score = 0
				  blocks = {}
				  block_gen_prob = 2
				  block_speed = 1
				  paused = false
				  center_print.active =
				  		false
				-- if not gameover
				-- pausing / resuming
				else
				  if paused then
				    center_print.active =
				      false
				    paused = false
				  else
				    center_print.active =
				      true
				    center_print.txt = 
				      "   paused"
				    paused = true
				  end
				end
		end
  if not paused then
		  -- animation counter reset
			 if (anim_cnt==30) anim_cnt = 0
			 if anim_cnt % 15 == 0 then
			   score+=1
			 end
				
			 -- checking button presses
		  -- up button pressed
				if (btn(⬆️) or btn(❎)) then
						up_pressed()
				-- no button pressed
				elseif btn(⬆️) == false and
											btn(⬇️) == false and
											btn(❎) == false then
				  no_pressed()
				-- down pressed
				elseif btn(⬇️) then
				  down_pressed()
				end
				
				
				-- generating blocks
				-- block_gen_prob val
				-- defines probability 
				-- and check that its not
				-- too close to next block
				if (rand_range(0,100) <
				    block_gen_prob) and
				    last_block_x() < 105
				    then
				  gen_block()
				end
				move_blocks()
				-- gen and move birds
				if (rand_range(0,100) <
				    birds_gen_prob) then
				  gen_bird()
				end
				move_birds()
				-- gen and move clouds
				if (rand_range(0,100) <
				    clouds_gen_prob) then
				  gen_cloud()
				end
				move_clouds()
				-- increase speed
				if block_speed < 5 then
				  block_speed += 0.002
				end
				-- increase block prob
				if block_gen_prob < 10 then
				  block_gen_prob += 0.002
				end
				-- move backgrnd mountains
				if anim_cnt % 1 == 0 then
				  move_mountains()
				end
				anim_cnt += 1
  end			
  
  		-- checking collision
			 		-- meaning game over
				if check_collis() then
				  game_over = true
				  paused = true
				  center_print.active=true
				  center_print.txt=
				  		"  game over"..
				  		"\n    press"..
				  		"\n     🅾️"..
				  		"\n to restart"
				  if score > highscore then
				    highscore = score
				    savehighscore()
				  end
				end
  	
  score_conf.txt = score
  highscore_print.txt =
  		highscore
		log.txt = tostr(
														highscore)
										
end

function _draw()
  -- clear screen
  cls()
  
  -- draw the floor
  rectfill(0, floor_y,
  									128, 128, 6)
  
  -- draw the sky
  rectfill(0,0,128,floor_y-1,12)
  
  -- draw all other elements
  clouds_draw()
  mountains_draw()
  plr_draw()
  blocks_draw()
  shadow_draw()
  birds_draw()
  draw_score()
  draw_center()
  draw_highscore()
  draw_log()
end
-->8
-- player

plr =
 {
  ["x"]=20,
  ["y"]=90, -- set in init
  ["spd"]=5, -- movement speed
  ["start_spd"]=5,
  ["is_fall"] = false,
  ["max_jmp"] = 50, -- max px
  ["hght"] = 8, -- height in px
  ["wdth"] = 8, -- width in px
  ["spr"] = 1,
  ["duck"] = false
 }
 
function plr_move(hght)
		-- if plr would be below flr
		if plr_cur_jmp() + hght
		   < 0 then
		  -- set on floor level
		  plr.y = floor_y -
		          plr.hght
		  shadow.dy = 85 // reset
		-- plr is above floor
		-- can be moved
		else
		  plr.y = plr.y - hght
		  shadow.dy = shadow.dy+hght
		  shadow.dx = shadow.dx+hght
		end
end

-- gets the current jump hght
-- of plr relative to floor
function plr_cur_jmp()
  return floor_y - plr.y -
          plr.hght 
  end
  
  
function plr_draw()
  -- not jumping
  if plr_cur_jmp() == 0 then
    -- if ducking
    if plr.duck then
      if anim_cnt % 5 == 0 then
				    if plr.spr == 15 then
				      plr.spr = 16
				      shadow.sx=77
				      shadow.dx=21
				    else
				      plr.spr = 15
				      shadow.sx=28
				      shadow.dx=20
				    end
				    shadow.dw=50
				    shadow.dh=25
				  end
				-- if normal walking
    else
				  if anim_cnt % 5 == 0 then
				    if plr.spr == 1 then
				      plr.spr = 2
				      shadow.sx=77
				      shadow.dx=21
				    else
				      plr.spr = 1
				      shadow.sx=28
				      shadow.dx=20
				    end
				    shadow.dw=50
				    shadow.dh=50
				  end
		  end
		-- jumping
		else
    -- if plr.spr not already
    -- one of the jump sprs
    if plr.spr < 3 or
       plr.spr >= 14 then
      plr.spr = 3
    else
      plr.spr += 1
    end
    if anim_cnt % 5 == 0 then
      if shadow.sx == 77 then
        shadow.sx = 28
      else
        shadow.sx=77
      end
    end
		end
  spr(plr.spr, plr.x, plr.y)
end
-->8
-- movement

function up_pressed()
  plr.duck = false
  if plr.is_fall then
    no_pressed()
  -- if can jump higher
  elseif plr.spd > 0.3 then
    plr_move(plr.spd)
    -- reducing asc speed
    if plr.spd > 0.3 then
      plr.spd = plr.spd * 
                (1-gravity)
    end
  else
    plr.is_fall = true
  end
end 

function no_pressed()
		plr.duck = false
  -- when plr hits floor
	 if plr.y + plr.hght >= floor_y then
	   plr.is_fall = false
	   plr.spd = plr.start_spd
	 else 
	   plr.is_fall = true
	   plr_move(-plr.spd)
	   plr.spd = plr.spd *
	             (1+gravity)
	 end
end

function down_pressed()
  -- when plr hits floor
	 if plr.y + plr.hght >= floor_y then
	   plr.is_fall = false
	   plr.spd = plr.start_spd
	   plr.duck = true
	 else 
	   plr.is_fall = true
	   -- move down
	   plr_move(-plr.spd)
	   -- move faster than normal
	   -- fall
	   plr.spd = (plr.spd *
	             (1+gravity)) * 2
	 end
end
-->8
-- text rendering

score_conf =
{
 ["active"] = true,
 ["txt"]    = "",
 ["x"]			   = 100,
 ["y"]      = 110,
 ["col"]    = 5
}

log =
{
 ["active"] = false,
 ["txt"]    = "",
 ["x"]			   = 9,
 ["y"]      = 18,
 ["col"]    = 7
}

highscore_print =
{
 ["active"] = true,
 ["txt"]    = "",
 ["x"]			   = 100,
 ["y"]      = 120,
 ["col"]    = 5
}

-- for printing text in screen
-- center eg pause / gameover
center_print =
{
 ["active"] = false,
 ["txt"]    = "",
 ["x"]			   = 40,
 ["y"]      = 30,
 ["col"]    = 7
}

-- drawing log on screen
function draw_log()
 if (log.active) then
  log.txt = "log: "..
   tostring(log.txt)
	 print(log.txt,
	       log.x, 
	       log.y,
	       log.col)
	 log.txt = ""
	end
end

-- drawing score on screen
function draw_score()
 if (score_conf.active) then
  score_conf.txt = "★ "..
   tostring(score_conf.txt)
	 print(score_conf.txt,
	       score_conf.x, 
	       score_conf.y,
	       score_conf.col)
	 score_conf.txt = ""
	end
end

-- drawing center print
-- on screen
function draw_center()
 if (center_print.active) then
	 print(center_print.txt,
	       center_print.x, 
	       center_print.y,
	       center_print.col)
	end
end

-- drawing highscore bot right
-- on screen
function draw_highscore()
 if (highscore_print.active) then
  highscore_print.txt = "◆"..
   tostring(highscore_print.txt)
	 print(highscore_print.txt,
	       highscore_print.x, 
	       highscore_print.y,
	       highscore_print.col)
	 highscore_print.txt = ""
	end
end
-->8
-- blocks

block_hght = 4
block_speed = 1
blocks = {}
block_clr = 1 // color

function gen_block()
  xr=128
  yr= rand_range(floor_y-
                 block_hght-
                 20,
                 floor_y-
                 block_hght-1)
  local block = {x=xr, y=yr} 
  add(blocks, block)
end

function blocks_draw()
		for block in all(blocks) do
		  rectfill(block.x, block.y,
		           block.x+block_hght, 
		           block.y+
		           block_hght,
		           block_clr)
		end
end

function move_blocks()
  for block in all(blocks) do
    block.x = block.x -
              block_speed
    if block.x < -block_hght
    then
      del(blocks, block)
    end
  end
end

function check_collis()
  for block in all(blocks) do
    -- if plr ducks
    if plr.duck and 
       plr_cur_jmp() == 0 then
		    if plr.x < block.x + block_hght and
				     plr.x + plr.wdth > block.x and
				     plr.y + (plr.hght/2) < block.y + block_hght and
				     plr.y + plr.hght/2 > block.y then
				     -- collision occurred
				     return true
				  end
		  -- if plr does not duck
    else 
    		-- check for collision between player and block
		    if plr.x < block.x + block_hght and
		       plr.x + plr.wdth > block.x and
		       plr.y < block.y + block_hght and
		       plr.y + plr.hght > block.y then
		      -- collision occurred
		      return true
		    end
    end
  end
  return false
end


-- gets x coord of last block
function last_block_x()
  if (#blocks > 0) then
    return (blocks[#blocks].x)
  else
  		return -1
  end
end
-->8
-- utils

function rand_range(min, max)
  return flr(rnd(max - min + 1)) + min
end
-->8
--environment

shadow =
{
 ["sx"] = 28,
 ["sy"] = 8,
 ["sw"]	= 48,
 ["sh"] = 50,
 ["dx"] = 20,
 ["dy"] = 85,
 ["dw"] = 50,
 ["dh"] = 50
}

function shadow_draw()
	sspr(shadow.sx,
      shadow.sy,
      shadow.sw,
      shadow.sh,
      shadow.dx,
      shadow.dy,
      shadow.dw,
      shadow.dh)
end

birds = {}

function gen_bird()
  xr=128
  yr= rand_range(0, 60)
  local bird = {x=xr,
                y=yr,
                speed=
                  rand_range(
                    1.2, 2),
                spr_id=128} 
  add(birds, bird)
end

function birds_draw()
		for bird in all(birds) do
		  -- animation handling
		  if anim_cnt % 5 == 0 then
		    if bird.spr_id < 133 then
		  				bird.spr_id += 1
		  		else
		  		  bird.spr_id = 128
		  		end
		  end
		  spr(bird.spr_id,
    bird.x,
    bird.y)
		end
end

function move_birds()
  for bird in all(birds) do
    bird.x = bird.x -
              bird.speed
    if bird.x < - block_hght
    then
      del(birds, bird)
    end
  end
end

clouds = {}

function gen_cloud()
  xr=128
  yr= rand_range(10, 40)
  local cloud = 
     {["sx"] = 64,
      ["sy"] = 72,
      ["sw"] = 32,
      ["sh"] = 32,
      ["dx"] = 128,
      ["dy"] = yr,
      ["dw"] = 32,
      ["dh"] = 32,
      ["speed"] = rand_range(
                    1.2, 2)} 
  add(clouds, cloud)
end

function clouds_draw()
		for cloud in all(clouds) do
		  -- animation handling
		  if anim_cnt % 15 == 0 then
		    -- stretching clouds for
		    -- animation
		    if 
		      cloud.dw == cloud.sw then
		      cloud.dw = cloud.sw + 5
		      cloud.dh = cloud.dh - 1
		    else
		      cloud.dw = cloud.sw
		      cloud.dh = cloud.sh
		    end
		  end
		  sspr(cloud.sx,
      cloud.sy,
      cloud.sw,
      cloud.sh,
      cloud.dx,
      cloud.dy,
      cloud.dw,
      cloud.dh)
		end
end

function move_clouds()
  for cloud in all(clouds) do
    cloud.dx = cloud.dx -
              cloud.speed
    if cloud.dx < - cloud.dw
    then
      del(clouds, cloud)
    end
  end
end

mountains_1 = {
 ["sx"] = 64,
 ["sy"] = 96,
 ["sw"]	= 128,
 ["sh"] = 31,
 ["dx"] = 0,
 ["dy"] = 23,
 ["dw"] = 256,
 ["dh"] = 62
}

mountains_2 = {
 ["sx"] = 64,
 ["sy"] = 96,
 ["sw"]	= 128,
 ["sh"] = 31,
 ["dx"] = 128,
 ["dy"] = 23,
 ["dw"] = 256,
 ["dh"] = 62
}

function move_mountains()
  if mountains_1.dx < -127 then
    mountains_1.dx = 127
  else
    mountains_1.dx -= 1
  end
  if mountains_2.dx < -127 then
    mountains_2.dx = 127
  else
    mountains_2.dx -= 1
  end
end

function mountains_draw()
  sspr(
      mountains_1.sx,
      mountains_1.sy,
      mountains_1.sw,
      mountains_1.sh,
      mountains_1.dx,
      mountains_1.dy,
      mountains_1.dw,
      mountains_1.dh)
      
  sspr(
      mountains_2.sx,
      mountains_2.sy,
      mountains_2.sw,
      mountains_2.sh,
      mountains_2.dx,
      mountains_2.dy,
      mountains_2.dw,
      mountains_2.dh)
end
-->8
-- cartdata loading / saving

function savehighscore()
  dset(0, highscore)
end

function loadhighscore()
  highscore = dget(0) or 0
end
__gfx__
00000000011111100000000000111100001111000011110000111100001111000011110000111100001111000011110000111100001111000011110000000000
00000000111111100111111001111110011111100111111001111110011111100111111001111110011111100111111001111110011111100111111000000000
00700700111177701111111001117770011777100177711007771110077111100711111001111110011111100111111001111110011111600111177000000000
00077000111111101111777001111110011111100111111001111110011111100111111001111110011111100111111001111110011111100111111000000000
00077000111111101111111001111110011111100111111001111110011111100111111001111110011111100111111001111110011111100111111001111110
00700700111111101111111001111110011111100111111000111100001111000011110001111110011111100111111000111100001111000011110011117770
00000000011101110111111000111100001111000011110000010100000101000001010000111100001111000011110000010100000101000001010011111111
00000000011101110111111000010100000101000001010000000000000000000000000000010100000101000001010000000000000000000000000001110111
00000000000000000000000000000555055500000000000000000000000000000000000000000555555000000000000000000000000000000000000000000000
00000000000000000000000000000555505550000000000000000000000000000000000000000555555555000000000000000000000000000000000000000000
00000000000000000000000000000555505555000000000000000000000000000000000000000555555555500000000000000000000000000000000000000000
00000000000000000000000000000055550555500000000000000000000000000000000000000055555555550000000000000000000000000000000000000000
00000000000000000000000000000055550055550000000000000000000000000000000000000055555555555000000000000000000000000000000000000000
01111110000000000000000000000005555005555000000000000000000000000000000000000005555555555500000000000000000000000000000000000000
11117770000000000000000000000005555505555550000000000000000000000000000000000005555555555550000000000000000000000000000000000000
01111110000000000000000000000005555500555555000000000000000000000000000000000005555555555555000000000000000000000000000000000000
00000000000000000000000000000000555550555555500000000000000000000000000000000000555555555555500000000000000000000000000000000000
00000000000000000000000000000000555550055555550000000000000000000000000000000000555555555555550000000000000000000000000000000000
00000000000000000000000000000000555555055555555000000000000000000000000000000000555555555555555000000000000000000000000000000000
00000000000000000000000000000000555555055555555500000000000000000000000000000000555555555555555500000000000000000000000000000000
00000000000000000000000000000000055555555555555550000000000000000000000000000000055555555555555550000000000000000000000000000000
00000000000000000000000000000000055555505555555555000000000000000000000000000000055555555555555555000000000000000000000000000000
00000000000000000000000000000000055555555555555555550000000000000000000000000000055555555555555555500000000000000000000000000000
00000000000000000000000000000000055555555555555555555000000000000000000000000000555555555555555555550000000000000000000000000000
00000000000000000000000000000000555555555555555555555500000000000000000000000000555555555555555555555500000000000000000000000000
00000000000000000000000000000000555555555555555555555500000000000000000000000000555555555555555555555550000000000000000000000000
00000000000000000000000000000000555555555555555555555555000000000000000000000000555555555555555555555555000000000000000000000000
00000000000000000000000000000005555555555555555555555555000000000000000000000000555555555555555555555555500000000000000000000000
00000000000000000000000000000005555555555555555555555555550000000000000000000000555555555555555555555555550000000000000000000000
00000000000000000000000000000005555555555555555555555555555000000000000000000000555555555555555555555555555000000000000000000000
00000000000000000000000000000005555555555555555555555555555500000000000000000000555555555555555555555555555500000000000000000000
00000000000000000000000000000005555555555555555555555555555550000000000000000000555555555555555555555555555550000000000000000000
00000000000000000000000000000005555555555555555555555555555555000000000000000000555555555555555555555555555555000000000000000000
00000000000000000000000000000005555555555555555555555555555555550000000000000000555555555555555555555555555555500000000000000000
00000000000000000000000000000005555555555555555555555555555555550000000000000000555555555555555555555555555555550000000000000000
00000000000000000000000000000005555555555555555555555555555555555000000000000000555555555555555555555555555555555000000000000000
00000000000000000000000000000005555555555555555555555555555555555500000000000000555555555555555555555555555555555500000000000000
00000000000000000000000000000005555555555555555555555555555555555550000000000000555555555555555555555555555555555550000000000000
00000000000000000000000000000005555555555555555555555555555555555555000000000000555555555555555555555555555555555550000000000000
00000000000000000000000000000005555555555555555555555555555555555555000000000000555555555555555555555555555555555555000000000000
00000000000000000000000000000005555555555555555555555555555555555555500000000000555555555555555555555555555555555555000000000000
00000000000000000000000000000005555555555555555555555555555555555555550000000000555555555555555555555555555555555555500000000000
00000000000000000000000000000000555555555555555555555555555555555555550000000000555555555555555555555555555555555555500000000000
00000000000000000000000000000000555555555555555555555555555555555555555000000000005555555555555555555555555555555555500000000000
00000000000000000000000000000000055555555555555555555555555555555555555000000000005555555555555555555555555555555555500000000000
00000000000000000000000000000000005555555555555555555555555555555555555000000000000555555555555555555555555555555555000000000000
00000000000000000000000000000000005555555555555555555555555555555555555000000000000555555555555555555555555555555550000000000000
00000000000000000000000000000000000055555555555555555555555555555555555000000000000055555555555555555555555555555000000000000000
00000000000000000000000000000000000005555555555555555555555555555555555000000000000005555555555555555555500000000000000000000000
00000000000000000000000000000000000005555555555555555555555555555550000000000000000000555555555555550000000000000000000000000000
00000000000000000000000000000000000000555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000055555555555555555555000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000010000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101000001010001110111000101000111011100010100000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010100110101100001000000010000000100001101011000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000666000000000000000000000000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066676600000000000000000000000000666766666000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066667776666600000000000000000000066677767776666000000000000000000000000000000000000000000000000000000000000000000000000000
00006667667777677666000000000000000006666677776777766000000000000000000000000000000000000000000000000000000000000000000000000000
00066677777777777660000000000000000006667777777776660000000000000000000000000000000000000000000000000000000000000000000000000000
00000667767777666600000066600000000000666677777766000000666600000000000000000000000000000000000000000000000000000000000000000000
06600066666776600000000600000000000000000067766000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000006666000000000000000000006000000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000000000000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666660000666666600000000000000006666600006660000000000000000000066666000066666660000000000000000000000000000000000000000
00000066677766666677777660000000000000066777666666776660000000000000006667776666667777766000000000000000000000000000000000000000
00000067777766777677777776666000000000677777667776777766000000000000006777776677767777777666600000000000000000000000000000000000
00006667777777777677777776666000000066677777777776777776600000000000666777777777767777777777600000000000000000000000000000000000
06666777777777777777777766000000000067777777777777777777660000000066677777777777777777777777660000000000000000000000000000000000
00667777777777777777777660000000000066667777777777777776000000000066777777777777777777777777660000000000000000000000000000000000
00066676777767777667766600066600000000066677677776677660000666000006667677776777766777777666600000000000000000000000000000000000
00000666677766776666660000600000000000000666667766666600000000600000066667776677666666776660000000000000000000000000000000000000
00000000666666666000000000000000000000000006666660000000000000000000000066666666600006666000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000066600666600000000000000000000066666006666000000000000000000000000000000000000000000000000000000000000000000
00000000600000000000067666777660000000000000000066667776667776600000000000000000000000000000000000000000000000000000000000000000
00000000066600000006677776777766000000000666000066777777767777660000000000000000000000000000000000000000000000000000000000000000
00000000000000000666667776777600000000000000600006677777767776600000000000000000000000000000000000000000000000000000000000000000
06006000000000000000066677766000000000000000000000666666777766000000000000000000000000000000000000000000000000000000000000000000
00660600000000000000000666660000006606000000000000000666666600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000066000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000066d000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000006d6d000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000006666dd00000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000006666dddd0000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000066666ddddd000000000000000660000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000066666dddddd00000000000000666d000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000d0000000006ddd66ddddddd000000000000666dd000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000dd00000066dd6666ddddddd00000000000666dddd00000000000000000000006
0000000000000000000000000000000000000000000000000000000000000000ddd0000666d6666ddddddddd00000000066666dddd0006600000000000000066
0000000000000000000000000000000000000000000000000000000000000000dddd0666666666dddddddddd000000000666d6ddddd066dd000000000000066d
0000000000000000000000000000000000000000000000000000000000000000ddddd666666666dddddddddd0000000066666dddddd06ddddd00000000000666
0000000000000000000000000000000000000000000000000000000000000000dddddd6d66666666dddddddddd00006666666ddddddddddddd0000000000066d
0000000000000000000000000000000000000000000000000000000000000000dddddd6666666666dddddddddddd06666666ddddddddddddddd00000000066dd
0000000000000000000000000000000000000000000000000000000000000000dddddd6666666666ddddddddddddd66666dddddddddddddddddd0000000666dd
0000000000000000000000000000000000000000000000000000000000000000dddddd6666666666dddddddddddddd6d66dddddddddddddddddd000000666ddd
0000000000000000000000000000000000000000000000000000000000000000dddddd666dd6666ddddddddddddddddd6ddddddddddddddddddddd000066dddd
0000000000000000000000000000000000000000000000000000000000000000dddddd6ddd6666dddddddddddddddddddddddddddddddddddddddddd066ddddd
0000000000000000000000000000000000000000000000000000000000000000ddddddd6666666dddddddddddddddddddddddddddddddddddddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000ddddddddddd666dddddddddddddddddddddddddddddddddddddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccc111c111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccc111c111cccccccc1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1c1ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11c1c11ccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccc1c1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccc11c1c11cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1c1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1c1c1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccccc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc6666cccccccccccc666666ccccc66666666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc6666cccccccccc6667777666666677777766cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6666ddcccccccccc677777766777767777777766666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6666ddccccc666677777777777777777777777777666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dd66ddccccc666777777777777777777777777777666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66
dd66ddcccccc6666767777767777766777777766666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66
6666ddddccccccc6666777766777666666777666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666
6666ddddcccccccccc66666666666cccc66666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666
66ddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666
66ddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666666
66ddddddddddcccccccccccccccccccccccccccccc6666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666
66ddddddddddcccccccccccccccccccccccccccccc6666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc66666666
ddddddddddddcccccccccccccccccccccccccccc666666ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666
ddddddddddddcccccccccccccccccccccccccccc666666ddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc6666666666
ddddddddddddddcccccccccccccccccccccccc666666ddddccccccccccccccccccccccccccccccccccccccccccccccccddcccccccccccccccccc66dddddd6666
ddddddddddddddcccccccccccccccccccccccc666666ddddccccccccccccccccccccccccccccccccccccccccccccccccddcccccccccccccccccc66dddddd6666
ddddddddddddddcccccccccccccccccccccc666666ddddddddcccccccccccccccccccccccccccccccccccccccccccc66ddddcccccccccccc6666dddd66666666
ddddddddddddddcccccccccccccccccccccc666666ddddddddcccccccccccccccccccccccccccccccccccccccccccc66ddddcccccccccccc6666dddd66666666
ddddddddddddddddcccccccccccccccccc6666666666ddddddddcccccc6666cccccccccccccccccccccccccccccc6666ddddddcccccccc666666dd66666666dd
ddddddddddddddddcccccccccccccccccc6666666666ddddddddcccccc6666cccccccccccccccccccccccccccccc6666ddddddcccccccc666666dd66666666dd
ddddddddddddddddcccccccccccccccccc666666dd66ddddddddddcc6666ddddcccccccccccccccccccccccccc6666ddddddddddcc666666666666666666dddd
ddddddddddddddddcccccccccccccccccc666666dd66ddddddddddcc6666ddddcccccccccccccccccccccccccc6666ddddddddddcc666666666666666666dddd
ddddddddddddddddcccccccccccccccc6666666666ddddddddddddcc66ddddddddddcccccccccccccccccccccc666666dddddddddd666666666666666666dddd
ddddddddddddddddcccccccccccccccc6666666666ddddddddddddcc66ddddddddddcccccccccccccccccccccc666666dddddddddd666666666666666666dddd
ddddddddddddddddddddcccccccc66666666666666ddddddddddddddddddddddddddcccccccccccccccccccccc6666dddddddddddddd66dd6666666666666666
ddddddddddddddddddddcccccccc66666666666666ddddddddddddddddddddddddddcccccccccccccccccccccc6666dddddddddddddd66dd6666666666666666
ddddddddddddddddddddddddcc66666666666666ddddddddddddddddddddddddddddddcccccccccccccccccc6666dddddddddddddddd66666666666666666666
ddddddddddddddddddddddddcc66666666666666ddddddddddddddddddddddddddddddcccccccccccccccccc6666dddddddddddddddd66666666666666666666
dddddddddddddddddddddddddd6666666666ddddddddddddddddddddddddddddddddddddcccccccccccccc666666dddddddddddddddd66666666666666666666
dddddddddddddddddddddddddd6666666666ddddddddddddddddddddddddddddddddddddcccccccccccccc666666dddddddddddddddd66666666666666666666
dddddddddddddddddddddddddddd66dd6666ddddddddddddddddddddddddddddddddddddcccccccccccc666666dddddddddddddddddd66666666666666666666
dddddddddddddddddddddddddddd66dd6666ddddddddddddddddddddddddddddddddddddcccccccccccc666666dddddddddddddddddd66666666666666666666
dddddddddddddddddddddddddddddddd66ddddddddddddddddddddddddddddddddddddddddddcccccccc6666dddddddddddddddddddd666666dddd66666666dd
dddddddddddddddddddddddddddddddd66ddddddddddddddddddddddddddddddddddddddddddcccccccc6666dddddddddddddddddddd666666dddd66666666dd
ddddddddddddddddddddd111111dddddddddddddddddddddddddddddddddddddddddddddddddddddcc6666dddddddddddddddddddddd66dddddd66666666dddd
dddddddddddddddddddd1111111dddddddddddddddddddddddddddddddddddddddddddddddddddddcc6666dddddddddddddddddddddd66dddddd66666666dddd
dddddddddddddddddddd1111777ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666666666666dddd
dddddddddddddddddddd1111111ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd66666666666666dddd
dddddddddddddddddddd1111111ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd666666dddd
dddddddddddddddddddd1111111ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd666666dddd
ddddddddddddddddddddd111d111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddd111d111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
66666666666666666666655565556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666655556555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666655556555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666665555655556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666665555665555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555566555556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555556555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555556655555556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555655555555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555665555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555565555555556666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555565555555555666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666665555555555555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666665555556655555555556666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666665555555555555555555566666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666665555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555555555555555555555666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555555555555555555555666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555566666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555566666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555555556666666666666666666666666666666666666666666665666666665666555666666666
66666666666666666666666555555555555555555555555555555555556666666666666666666666666666666666666666666655566666665666665666666666
66666666666666666666666555555555555555555555555555555555555666666666666666666666666666666666666666665555555666665556555666666666
66666666666666666666666555555555555555555555555555555555555566666666666666666666666666666666666666666555556666665656566666666666
66666666666666666666666555555555555555555555555555555555555556666666666666666666666666666666666666666566656666665556555666666666
66666666666666666666666555555555555555555555555555555555555555666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555555555555666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555555555555566666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666555555555555555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555555555555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666655555555555555555555555555555555555555555666666666666666666666666666666666666665666655665566566666666666
66666666666666666666666665555555555555555555555555555555555555555666666666666666666666666666666666666655566665666566566666666666
66666666666666666666666666555555555555555555555555555555555555555666666666666666666666666666666666666555556665666566555666666666
66666666666666666666666666555555555555555555555555555555555555555666666666666666666666666666666666666655566665666566565666666666
66666666666666666666666666665555555555555555555555555555555555555666666666666666666666666666666666666665666655565556555666666666
66666666666666666666666666666555555555555555555555555555555555555666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666555555555555555555555555555555556666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666655555555555555555555555555555666666666666666666666666666666666666666666666666666666666666666666666

__map__
0011616263646566676861626364656600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112131415161718111213141516171800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122111111111111112223242526272800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132111111111111113233343536373800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4111111111111111114243444546474800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5111110011111111115253545556575800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6111116411111111116263646566676800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7172737475767778717273747576777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8182838485868788818283848586878800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000254003510045200652007530085300a5300c5300d5300f55010550115501455016550195501c55020550255502a55030550000000000000000000000000000000000000000000000000000000000000
001400001b0101b01019020140201002012020140201d0201e0201e0201e0201e0200302003020030200302003020030200502003020030200302003020030200302003050050200402004020040200402004050
