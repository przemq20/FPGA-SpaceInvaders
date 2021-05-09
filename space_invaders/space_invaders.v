//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module space_invaders(

	//////////// CLOCK //////////
	input clk,

	//////////// LED //////////
	output [9:0] LEDR,
	input  [1:0] KEY,
	//////////// VGA //////////
	output VGA_hSync,
	output VGA_vSync, 
	output [3:0] Red, Green, Blue,

	//////////// Keyboard //////////
	input kData, 
	input kClock 
);
	integer i; // for iterations
	integer j;
	//vga
	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
		
	//clock
	wire clk25MHz;
	wire clk_move;
	
	//player
	integer size_x = 20;
	integer size_y = 30;
	integer position_x = (640/2) + 144;
	integer position_y = 450;
	wire  [2:0] direction_x;
	integer direction_y = 0;
	
	// enemy	
	integer enemy_x_pos[17:0];
	integer enemy_y_pos[17:0];
	reg enemy_direction = 1'b0;
	reg enemy_alive[17:0];
	
	//obstacles
	integer obstacle_x_pos[3:0];
	integer obstacle_y_pos[3:0];
	integer obstacle_life[3:0];
	integer obstacle_x_size = 50;
	integer obstacle_y_size = 20;

	initial
	begin
		obstacle_x_pos[0] = 247;
		obstacle_y_pos[0] = 400;
		obstacle_x_pos[1] = 375;
		obstacle_y_pos[1] = 400;
		obstacle_x_pos[2] = 503;
		obstacle_y_pos[2] = 400;
		obstacle_x_pos[3] = 631;
		obstacle_y_pos[3] = 400;
		
		obstacle_life[0] = 4;
		obstacle_life[1] = 4;
		obstacle_life[2] = 4;
		obstacle_life[3] = 4;
		
		enemy_x_pos[0] = 200;
		enemy_y_pos[0] = 40;
		enemy_alive[0] = 1'b1;

		enemy_x_pos[1] = 260;
		enemy_y_pos[1] = 40;
		enemy_alive[1] = 1'b1;		
		
		enemy_x_pos[2] = 320;
		enemy_y_pos[2] = 40;
		enemy_alive[2] = 1'b1;

		enemy_x_pos[3] = 380;
		enemy_y_pos[3] = 40;
		enemy_alive[3] = 1'b1;	
		
		enemy_x_pos[4] = 440;
		enemy_y_pos[4] = 40;
		enemy_alive[4] = 1'b1;

		enemy_x_pos[5] = 500;
		enemy_y_pos[5] = 40;
		enemy_alive[5] = 1'b1;		
		
		enemy_x_pos[6] = 560;
		enemy_y_pos[6] = 40;
		enemy_alive[6] = 1'b1;

		enemy_x_pos[7] = 620;
		enemy_y_pos[7] = 40;
		enemy_alive[7] = 1'b1;	
		
		enemy_x_pos[8] = 680;
		enemy_y_pos[8] = 40;
		enemy_alive[8] = 1'b1;	
		
		enemy_x_pos[9] = 200;
		enemy_y_pos[9] = 100;
		enemy_alive[9] = 1'b1;

		enemy_x_pos[10] = 260;
		enemy_y_pos[10] = 100;
		enemy_alive[10] = 1'b1;		
		
		enemy_x_pos[11] = 320;
		enemy_y_pos[11] = 100;
		enemy_alive[11] = 1'b1;

		enemy_x_pos[12] = 380;
		enemy_y_pos[12] = 100;
		enemy_alive[12] = 1'b1;	
		
		enemy_x_pos[13] = 440;
		enemy_y_pos[13] = 100;
		enemy_alive[13] = 1'b1;

		enemy_x_pos[14] = 500;
		enemy_y_pos[14] = 100;
		enemy_alive[14] = 1'b1;		
		
		enemy_x_pos[15] = 560;
		enemy_y_pos[15] = 100;
		enemy_alive[15] = 1'b1;

		enemy_x_pos[16] = 620;
		enemy_y_pos[16] = 100;
		enemy_alive[16] = 1'b1;	
		
		enemy_x_pos[17] = 680;
		enemy_y_pos[17] = 100;
		enemy_alive[17] = 1'b1;	
	end

	integer enemy_size = 20;

	//bullet
	integer bullet_x = 0;
	integer bullet_y = 0;
	integer bullet_size = 10;
	wire fired;
	integer bullet_clk = 0;
	reg bullet_free = 1'b1;
	
	//points
	reg [6:0] digit1 = 7'b0111111;
	reg [6:0] digit2 = 7'b0111111;
	integer points = 0;
	
	//logic
	integer level = 1;
	integer killed = 0;
	reg pause = 1'b1;
	reg lost = 1'b0;
	
	move_clk update_clk(clk, clk_move);
	vga_clk vga_reduce(clk, clk25MHz);
	keyboard move(kData, kClock, direction_x, LEDR, fired);
	
	
	// counter and sync generation
	always @(posedge clk25MHz)  // horizontal counter
	begin 
		if (counter_x < 799)
			counter_x <= counter_x + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
		else
			counter_x <= 0;              
	end  
	
	always @ (posedge clk25MHz)  // vertical counter
	begin 
		if (counter_x == 799)  // only counts up 1 count after horizontal finishes 800 counts
		begin
			if (counter_y < 525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
				counter_y <= counter_y + 1;
			else
				counter_y <= 0;              
		end  
	end  

   // hsync and vsync output assignments
	assign VGA_hSync = (counter_x >= 0 && counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign VGA_vSync = (counter_y >= 0 && counter_y < 2) ? 1:0;   // vsync high for 2 counts

	always@(points)
	begin 
		case(points % 10) //first digit
		0: digit1 <= 7'b0111111;
		1: digit1 <= 7'b0000110;
		2: digit1 <= 7'b1011011;
		3: digit1 <= 7'b1001111;
		4: digit1 <= 7'b1100110;
		5: digit1 <= 7'b1101101;
		6: digit1 <= 7'b1111101;
		7: digit1 <= 7'b0000111;
		8: digit1 <= 7'b1111111;
		9: digit1 <= 7'b1101111;
		endcase
		
		case( (points % 100) / 10) //second digit
		0: digit2 <= 7'b0111111;
		1: digit2 <= 7'b0000110;
		2: digit2 <= 7'b1011011;
		3: digit2 <= 7'b1001111;
		4: digit2 <= 7'b1100110;
		5: digit2 <= 7'b1101101;
		6: digit2 <= 7'b1111101;
		7: digit2 <= 7'b0000111;
		8: digit2 <= 7'b1111111;
		9: digit2 <= 7'b1101111;
		endcase
	end
	
	always @ (posedge clk25MHz)
	begin
		//if game is lost show red screen 
		if(lost == 1'b1)
		begin
			if(		
		(digit2[0] && counter_y >= 255 && counter_y < 260 && counter_x >= 445 && counter_x < 460) ||
		(digit2[1] && counter_y >= 260 && counter_y < 275 && counter_x >= 460 && counter_x < 465) ||
		(digit2[2] && counter_y >= 280 && counter_y < 295 && counter_x >= 460 && counter_x < 465) ||
		(digit2[3] && counter_y >= 295 && counter_y < 300 && counter_x >= 445 && counter_x < 460) ||
		(digit2[4] && counter_y >= 280 && counter_y < 295 && counter_x >= 440 && counter_x < 445) ||
		(digit2[5] && counter_y >= 260 && counter_y < 275 && counter_x >= 440 && counter_x < 445) ||
		(digit2[6] && counter_y >= 275 && counter_y < 280 && counter_x >= 445 && counter_x < 460) ||
		
		(digit1[0] && counter_y >= 255 && counter_y < 260 && counter_x >= 475 && counter_x < 490) ||
		(digit1[1] && counter_y >= 260 && counter_y < 275 && counter_x >= 490 && counter_x < 495) ||
		(digit1[2] && counter_y >= 280 && counter_y < 295 && counter_x >= 490 && counter_x < 495) ||
		(digit1[3] && counter_y >= 295 && counter_y < 300 && counter_x >= 475 && counter_x < 490) ||
		(digit1[4] && counter_y >= 280 && counter_y < 295 && counter_x >= 470 && counter_x < 475) ||
		(digit1[5] && counter_y >= 260 && counter_y < 275 && counter_x >= 470 && counter_x < 475) ||
		(digit1[6] && counter_y >= 275 && counter_y < 280 && counter_x >= 475 && counter_x < 490) 
		)
			begin
				r_red <= 4'hF;    
				r_blue <= 4'hF;
				r_green <= 4'hF;
			end
			else
			begin
				r_red <= 4'h8;    
				r_blue <= 4'h0;
				r_green <= 4'h0;
			end
		end
		//conditions for every object on screen
      else if ((counter_y >= position_y && counter_y < position_y+size_y && counter_x >= position_x && counter_x < position_x + size_x) ||
		(counter_y >= enemy_y_pos[0] && counter_y < enemy_y_pos[0] + enemy_size && counter_x >= enemy_x_pos[0] && counter_x < enemy_x_pos[0] + enemy_size) ||
		(counter_y >= enemy_y_pos[1] && counter_y < enemy_y_pos[1] + enemy_size && counter_x >= enemy_x_pos[1] && counter_x < enemy_x_pos[1] + enemy_size) ||
		(counter_y >= enemy_y_pos[2] && counter_y < enemy_y_pos[2] + enemy_size && counter_x >= enemy_x_pos[2] && counter_x < enemy_x_pos[2] + enemy_size) ||
		(counter_y >= enemy_y_pos[3] && counter_y < enemy_y_pos[3] + enemy_size && counter_x >= enemy_x_pos[3] && counter_x < enemy_x_pos[3] + enemy_size) ||
		(counter_y >= enemy_y_pos[4] && counter_y < enemy_y_pos[4] + enemy_size && counter_x >= enemy_x_pos[4] && counter_x < enemy_x_pos[4] + enemy_size) ||
		(counter_y >= enemy_y_pos[5] && counter_y < enemy_y_pos[5] + enemy_size && counter_x >= enemy_x_pos[5] && counter_x < enemy_x_pos[5] + enemy_size) ||
		(counter_y >= enemy_y_pos[6] && counter_y < enemy_y_pos[6] + enemy_size && counter_x >= enemy_x_pos[6] && counter_x < enemy_x_pos[6] + enemy_size) ||
		(counter_y >= enemy_y_pos[7] && counter_y < enemy_y_pos[7] + enemy_size && counter_x >= enemy_x_pos[7] && counter_x < enemy_x_pos[7] + enemy_size) ||
		(counter_y >= enemy_y_pos[8] && counter_y < enemy_y_pos[8] + enemy_size && counter_x >= enemy_x_pos[8] && counter_x < enemy_x_pos[8] + enemy_size) ||
		(counter_y >= enemy_y_pos[9] && counter_y < enemy_y_pos[9] + enemy_size && counter_x >= enemy_x_pos[9] && counter_x < enemy_x_pos[9] + enemy_size) ||
		(counter_y >= enemy_y_pos[10] && counter_y < enemy_y_pos[10] + enemy_size && counter_x >= enemy_x_pos[10] && counter_x < enemy_x_pos[10] + enemy_size) ||
		(counter_y >= enemy_y_pos[11] && counter_y < enemy_y_pos[11] + enemy_size && counter_x >= enemy_x_pos[11] && counter_x < enemy_x_pos[11] + enemy_size) ||
		(counter_y >= enemy_y_pos[12] && counter_y < enemy_y_pos[12] + enemy_size && counter_x >= enemy_x_pos[12] && counter_x < enemy_x_pos[12] + enemy_size) ||
		(counter_y >= enemy_y_pos[13] && counter_y < enemy_y_pos[13] + enemy_size && counter_x >= enemy_x_pos[13] && counter_x < enemy_x_pos[13] + enemy_size) ||
		(counter_y >= enemy_y_pos[14] && counter_y < enemy_y_pos[14] + enemy_size && counter_x >= enemy_x_pos[14] && counter_x < enemy_x_pos[14] + enemy_size) ||
		(counter_y >= enemy_y_pos[15] && counter_y < enemy_y_pos[15] + enemy_size && counter_x >= enemy_x_pos[15] && counter_x < enemy_x_pos[15] + enemy_size) ||
		(counter_y >= enemy_y_pos[16] && counter_y < enemy_y_pos[16] + enemy_size && counter_x >= enemy_x_pos[16] && counter_x < enemy_x_pos[16] + enemy_size) ||
		(counter_y >= enemy_y_pos[17] && counter_y < enemy_y_pos[17] + enemy_size && counter_x >= enemy_x_pos[17] && counter_x < enemy_x_pos[17] + enemy_size) ||

		
		(counter_y >= bullet_y && counter_y < bullet_y + bullet_size && counter_x >= bullet_x && counter_x < bullet_x + bullet_size) ||
		
		((counter_y >= obstacle_y_pos[0] && counter_y < obstacle_y_pos[0] + obstacle_y_size && counter_x >= obstacle_x_pos[0] && counter_x < obstacle_x_pos[0] + obstacle_x_size) && obstacle_life[0] > 0) ||
		((counter_y >= obstacle_y_pos[1] && counter_y < obstacle_y_pos[1] + obstacle_y_size && counter_x >= obstacle_x_pos[1] && counter_x < obstacle_x_pos[1] + obstacle_x_size) && obstacle_life[1] > 0) ||
		((counter_y >= obstacle_y_pos[2] && counter_y < obstacle_y_pos[2] + obstacle_y_size && counter_x >= obstacle_x_pos[2] && counter_x < obstacle_x_pos[2] + obstacle_x_size) && obstacle_life[2] > 0) ||
		((counter_y >= obstacle_y_pos[3] && counter_y < obstacle_y_pos[3] + obstacle_y_size && counter_x >= obstacle_x_pos[3] && counter_x < obstacle_x_pos[3] + obstacle_x_size) && obstacle_life[3] > 0) ||

		(digit1[0] && counter_y >= 40 && counter_y < 45 && counter_x >= 755 && counter_x < 770) ||
		(digit1[1] && counter_y >= 45 && counter_y < 60 && counter_x >= 770 && counter_x < 775) ||
		(digit1[2] && counter_y >= 65 && counter_y < 80 && counter_x >= 770 && counter_x < 775) ||
		(digit1[3] && counter_y >= 80 && counter_y < 85 && counter_x >= 755 && counter_x < 770) ||
		(digit1[4] && counter_y >= 65 && counter_y < 80 && counter_x >= 750 && counter_x < 755) ||
		(digit1[5] && counter_y >= 45 && counter_y < 60 && counter_x >= 750 && counter_x < 755) ||
		(digit1[6] && counter_y >= 60 && counter_y < 65 && counter_x >= 755 && counter_x < 770) ||
		
		(digit2[0] && counter_y >= 40 && counter_y < 45 && counter_x >= 725 && counter_x < 740) ||
		(digit2[1] && counter_y >= 45 && counter_y < 60 && counter_x >= 740 && counter_x < 745) ||
		(digit2[2] && counter_y >= 65 && counter_y < 80 && counter_x >= 740 && counter_x < 745) ||
		(digit2[3] && counter_y >= 80 && counter_y < 85 && counter_x >= 725 && counter_x < 740) ||
		(digit2[4] && counter_y >= 65 && counter_y < 80 && counter_x >= 720 && counter_x < 725) ||
		(digit2[5] && counter_y >= 45 && counter_y < 60 && counter_x >= 720 && counter_x < 725) ||
		(digit2[6] && counter_y >= 60 && counter_y < 65 && counter_x >= 725 && counter_x < 740) 
		)
		begin
			//color enemies red
			if(
			(counter_y >= enemy_y_pos[0] && counter_y < enemy_y_pos[0] + enemy_size && counter_x >= enemy_x_pos[0] && counter_x < enemy_x_pos[0] + enemy_size) ||
			(counter_y >= enemy_y_pos[1] && counter_y < enemy_y_pos[1] + enemy_size && counter_x >= enemy_x_pos[1] && counter_x < enemy_x_pos[1] + enemy_size) ||
			(counter_y >= enemy_y_pos[2] && counter_y < enemy_y_pos[2] + enemy_size && counter_x >= enemy_x_pos[2] && counter_x < enemy_x_pos[2] + enemy_size) ||
			(counter_y >= enemy_y_pos[3] && counter_y < enemy_y_pos[3] + enemy_size && counter_x >= enemy_x_pos[3] && counter_x < enemy_x_pos[3] + enemy_size) ||
			(counter_y >= enemy_y_pos[4] && counter_y < enemy_y_pos[4] + enemy_size && counter_x >= enemy_x_pos[4] && counter_x < enemy_x_pos[4] + enemy_size) ||
			(counter_y >= enemy_y_pos[5] && counter_y < enemy_y_pos[5] + enemy_size && counter_x >= enemy_x_pos[5] && counter_x < enemy_x_pos[5] + enemy_size) ||
			(counter_y >= enemy_y_pos[6] && counter_y < enemy_y_pos[6] + enemy_size && counter_x >= enemy_x_pos[6] && counter_x < enemy_x_pos[6] + enemy_size) ||
			(counter_y >= enemy_y_pos[7] && counter_y < enemy_y_pos[7] + enemy_size && counter_x >= enemy_x_pos[7] && counter_x < enemy_x_pos[7] + enemy_size) ||
			(counter_y >= enemy_y_pos[8] && counter_y < enemy_y_pos[8] + enemy_size && counter_x >= enemy_x_pos[8] && counter_x < enemy_x_pos[8] + enemy_size) ||
			(counter_y >= enemy_y_pos[9] && counter_y < enemy_y_pos[9] + enemy_size && counter_x >= enemy_x_pos[9] && counter_x < enemy_x_pos[9] + enemy_size) ||
			(counter_y >= enemy_y_pos[10] && counter_y < enemy_y_pos[10] + enemy_size && counter_x >= enemy_x_pos[10] && counter_x < enemy_x_pos[10] + enemy_size) ||
			(counter_y >= enemy_y_pos[11] && counter_y < enemy_y_pos[11] + enemy_size && counter_x >= enemy_x_pos[11] && counter_x < enemy_x_pos[11] + enemy_size) ||
			(counter_y >= enemy_y_pos[12] && counter_y < enemy_y_pos[12] + enemy_size && counter_x >= enemy_x_pos[12] && counter_x < enemy_x_pos[12] + enemy_size) ||
			(counter_y >= enemy_y_pos[13] && counter_y < enemy_y_pos[13] + enemy_size && counter_x >= enemy_x_pos[13] && counter_x < enemy_x_pos[13] + enemy_size) ||
			(counter_y >= enemy_y_pos[14] && counter_y < enemy_y_pos[14] + enemy_size && counter_x >= enemy_x_pos[14] && counter_x < enemy_x_pos[14] + enemy_size) ||
			(counter_y >= enemy_y_pos[15] && counter_y < enemy_y_pos[15] + enemy_size && counter_x >= enemy_x_pos[15] && counter_x < enemy_x_pos[15] + enemy_size) ||
			(counter_y >= enemy_y_pos[16] && counter_y < enemy_y_pos[16] + enemy_size && counter_x >= enemy_x_pos[16] && counter_x < enemy_x_pos[16] + enemy_size) ||
			(counter_y >= enemy_y_pos[17] && counter_y < enemy_y_pos[17] + enemy_size && counter_x >= enemy_x_pos[17] && counter_x < enemy_x_pos[17] + enemy_size)
			)
			begin	
				r_red <= 4'hF;    
				r_blue <= 4'h0;
				r_green <= 4'h0;
			end
			//color obstacles
			else if (counter_y >= obstacle_y_pos[0] && counter_y < obstacle_y_pos[0] + obstacle_y_size && 
			counter_x >= obstacle_x_pos[0] && counter_x < obstacle_x_pos[0] + obstacle_x_size && obstacle_life[0] > 0 )
			begin 
				if (obstacle_life[0] == 4)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h0;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[0] == 3)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h4;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[0] == 2)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h8;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[0] == 1)
				begin
					r_red <= 4'h3;    
					r_green <= 4'hC;
					r_blue <= 4'hF;
				end
			end
			else if (counter_y >= obstacle_y_pos[1] && counter_y < obstacle_y_pos[1] + obstacle_y_size && 
			counter_x >= obstacle_x_pos[1] && counter_x < obstacle_x_pos[1] + obstacle_x_size && obstacle_life[1] > 0)
			begin 
				if (obstacle_life[1] == 4)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h0;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[1] == 3)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h4;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[1] == 2)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h8;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[1] == 1)
				begin
					r_red <= 4'h3;    
					r_green <= 4'hC;
					r_blue <= 4'hF;
				end
			end
			else if (counter_y >= obstacle_y_pos[2] && counter_y < obstacle_y_pos[2] + obstacle_y_size && 
			counter_x >= obstacle_x_pos[2] && counter_x < obstacle_x_pos[2] + obstacle_x_size && obstacle_life[2] > 0)
			begin 
				if (obstacle_life[2] == 4)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h0;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[2] == 3)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h4;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[2] == 2)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h8;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[2] == 1)
				begin
					r_red <= 4'h3;    
					r_green <= 4'hC;
					r_blue <= 4'hF;
				end
			end
			else if (counter_y >= obstacle_y_pos[3] && counter_y < obstacle_y_pos[3] + obstacle_y_size && 
			counter_x >= obstacle_x_pos[3] && counter_x < obstacle_x_pos[3] + obstacle_x_size && obstacle_life[3] > 0)
			begin 
				if (obstacle_life[3] == 4)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h0;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[3] == 3)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h4;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[3] == 2)
				begin
					r_red <= 4'h3;    
					r_green <= 4'h8;
					r_blue <= 4'hF;
				end
				else if (obstacle_life[3] == 1)
				begin
					r_red <= 4'h3;    
					r_green <= 4'hC;
					r_blue <= 4'hF;
				end
			end
			//color everything else what should be shown white
			else
			begin
				r_red <= 4'hF;    
				r_blue <= 4'hF;
				r_green <= 4'hF;
			end
		end 
		//color everything else black
		else 
		begin
			r_red <= 4'h0;    
			r_blue <= 4'h0;
			r_green <= 4'h0;
		end
	end
	
	always@(posedge clk_move)
	begin
		if(KEY[0] == 1'b0)
			pause = 1'b1;
		
		if(KEY[1] == 1'b0)
		begin
			pause = 1'b0;
			if(lost == 1'b1)
			begin
				lost = 1'b0;
				level = 1;
				killed = 0;
				points = 0;
				
				enemy_x_pos[0] = 200;
				enemy_y_pos[0] = 40;
				enemy_alive[0] = 1'b1;

				enemy_x_pos[1] = 260;
				enemy_y_pos[1] = 40;
				enemy_alive[1] = 1'b1;		
				
				enemy_x_pos[2] = 320;
				enemy_y_pos[2] = 40;
				enemy_alive[2] = 1'b1;

				enemy_x_pos[3] = 380;
				enemy_y_pos[3] = 40;
				enemy_alive[3] = 1'b1;	
				
				enemy_x_pos[4] = 440;
				enemy_y_pos[4] = 40;
				enemy_alive[4] = 1'b1;

				enemy_x_pos[5] = 500;
				enemy_y_pos[5] = 40;
				enemy_alive[5] = 1'b1;		
				
				enemy_x_pos[6] = 560;
				enemy_y_pos[6] = 40;
				enemy_alive[6] = 1'b1;

				enemy_x_pos[7] = 620;
				enemy_y_pos[7] = 40;
				enemy_alive[7] = 1'b1;	
				
				enemy_x_pos[8] = 680;
				enemy_y_pos[8] = 40;
				enemy_alive[8] = 1'b1;	
				
				enemy_x_pos[9] = 200;
				enemy_y_pos[9] = 100;
				enemy_alive[9] = 1'b1;

				enemy_x_pos[10] = 260;
				enemy_y_pos[10] = 100;
				enemy_alive[10] = 1'b1;		
				
				enemy_x_pos[11] = 320;
				enemy_y_pos[11] = 100;
				enemy_alive[11] = 1'b1;

				enemy_x_pos[12] = 380;
				enemy_y_pos[12] = 100;
				enemy_alive[12] = 1'b1;	
				
				enemy_x_pos[13] = 440;
				enemy_y_pos[13] = 100;
				enemy_alive[13] = 1'b1;

				enemy_x_pos[14] = 500;
				enemy_y_pos[14] = 100;
				enemy_alive[14] = 1'b1;		
				
				enemy_x_pos[15] = 560;
				enemy_y_pos[15] = 100;
				enemy_alive[15] = 1'b1;

				enemy_x_pos[16] = 620;
				enemy_y_pos[16] = 100;
				enemy_alive[16] = 1'b1;	
				
				enemy_x_pos[17] = 680;
				enemy_y_pos[17] = 100;
				enemy_alive[17] = 1'b1;		
				
				obstacle_x_pos[0] = 247;
				obstacle_y_pos[0] = 400;
				obstacle_x_pos[1] = 375;
				obstacle_y_pos[1] = 400;
				obstacle_x_pos[2] = 503;
				obstacle_y_pos[2] = 400;
				obstacle_x_pos[3] = 631;
				obstacle_y_pos[3] = 400;
				
				obstacle_life[0] = 4;
				obstacle_life[1] = 4;
				obstacle_life[2] = 4;
				obstacle_life[3] = 4;
				
				bullet_x = 0;
				bullet_y = 0;
				bullet_free = 1'b1;
				
				position_x = (640/2) + 144;
				position_y = 450;
			end
				
		end
		
		if(pause == 1'b0 && lost == 1'b0 )
		begin
		
			if(direction_x == 1)
				position_x = position_x - 10;
			else if(direction_x == 2)
				position_x = position_x + 10;
			
			if(position_x > 783 - size_x)
				position_x = 144;
			else if(position_x < 144)
				position_x = 783 - size_x;
			
			// enemy
			// enemy: move x
			begin
				if(enemy_direction == 1'b0)
				begin	
					enemy_x_pos[0] = enemy_x_pos[0] + (level*2);
					enemy_x_pos[1] = enemy_x_pos[1] + (level*2);
					enemy_x_pos[2] = enemy_x_pos[2] + (level*2);
					enemy_x_pos[3] = enemy_x_pos[3] + (level*2);
					enemy_x_pos[4] = enemy_x_pos[4] + (level*2);
					enemy_x_pos[5] = enemy_x_pos[5] + (level*2);
					enemy_x_pos[6] = enemy_x_pos[6] + (level*2);
					enemy_x_pos[7] = enemy_x_pos[7] + (level*2);
					enemy_x_pos[8] = enemy_x_pos[8] + (level*2);
					enemy_x_pos[9] = enemy_x_pos[9] + (level*2);
					enemy_x_pos[10] = enemy_x_pos[10] + (level*2);
					enemy_x_pos[11] = enemy_x_pos[11] + (level*2);
					enemy_x_pos[12] = enemy_x_pos[12] + (level*2);
					enemy_x_pos[13] = enemy_x_pos[13] + (level*2);
					enemy_x_pos[14] = enemy_x_pos[14] + (level*2);
					enemy_x_pos[15] = enemy_x_pos[15] + (level*2);
					enemy_x_pos[16] = enemy_x_pos[16] + (level*2);
					enemy_x_pos[17] = enemy_x_pos[17] + (level*2);
				end
				else 
				begin
					enemy_x_pos[0] = enemy_x_pos[0] - (level*2);
					enemy_x_pos[1] = enemy_x_pos[1] - (level*2);
					enemy_x_pos[2] = enemy_x_pos[2] - (level*2);
					enemy_x_pos[3] = enemy_x_pos[3] - (level*2);
					enemy_x_pos[4] = enemy_x_pos[4] - (level*2);
					enemy_x_pos[5] = enemy_x_pos[5] - (level*2);
					enemy_x_pos[6] = enemy_x_pos[6] - (level*2);
					enemy_x_pos[7] = enemy_x_pos[7] - (level*2);
					enemy_x_pos[8] = enemy_x_pos[8] - (level*2);
					enemy_x_pos[9] = enemy_x_pos[9] - (level*2);
					enemy_x_pos[10] = enemy_x_pos[10] - (level*2);
					enemy_x_pos[11] = enemy_x_pos[11] - (level*2);
					enemy_x_pos[12] = enemy_x_pos[12] - (level*2);
					enemy_x_pos[13] = enemy_x_pos[13] - (level*2);
					enemy_x_pos[14] = enemy_x_pos[14] - (level*2);
					enemy_x_pos[15] = enemy_x_pos[15] - (level*2);
					enemy_x_pos[16] = enemy_x_pos[16] - (level*2);
					enemy_x_pos[17] = enemy_x_pos[17] - (level*2);
				end
			end
			
			// enemy: move down when chaneging a direction
			if(((enemy_x_pos[0] > 784 || enemy_x_pos[0] + enemy_size < 144) && enemy_alive[0]) || 
			((enemy_x_pos[1] > 784 || enemy_x_pos[1] + enemy_size < 144) && enemy_alive[1]) ||
			((enemy_x_pos[2] > 784 || enemy_x_pos[2] + enemy_size < 144) && enemy_alive[2]) ||
			((enemy_x_pos[3] > 784 || enemy_x_pos[3] + enemy_size < 144) && enemy_alive[3]) ||
			((enemy_x_pos[4] > 784 || enemy_x_pos[4] + enemy_size < 144) && enemy_alive[4]) ||
			((enemy_x_pos[5] > 784 || enemy_x_pos[5] + enemy_size < 144) && enemy_alive[5]) ||
			((enemy_x_pos[6] > 784 || enemy_x_pos[6] + enemy_size < 144) && enemy_alive[6]) ||
			((enemy_x_pos[7] > 784 || enemy_x_pos[7] + enemy_size < 144) && enemy_alive[7]) ||
			((enemy_x_pos[8] > 784 || enemy_x_pos[8] + enemy_size < 144) && enemy_alive[8]) ||
			((enemy_x_pos[9] > 784 || enemy_x_pos[9] + enemy_size < 144) && enemy_alive[9]) || 
			((enemy_x_pos[10] > 784 || enemy_x_pos[10] + enemy_size < 144) && enemy_alive[10]) ||
			((enemy_x_pos[11] > 784 || enemy_x_pos[11] + enemy_size < 144) && enemy_alive[11]) ||
			((enemy_x_pos[12] > 784 || enemy_x_pos[12] + enemy_size < 144) && enemy_alive[12]) ||
			((enemy_x_pos[13] > 784 || enemy_x_pos[13] + enemy_size < 144) && enemy_alive[13]) ||
			((enemy_x_pos[14] > 784 || enemy_x_pos[14] + enemy_size < 144) && enemy_alive[14]) ||
			((enemy_x_pos[15] > 784 || enemy_x_pos[15] + enemy_size < 144) && enemy_alive[15]) ||
			((enemy_x_pos[16] > 784 || enemy_x_pos[16] + enemy_size < 144) && enemy_alive[16]) ||
			((enemy_x_pos[17] > 784 || enemy_x_pos[17] + enemy_size < 144) && enemy_alive[17])
			)		
			begin
				enemy_direction = ~enemy_direction;
				if(enemy_alive[0]) enemy_y_pos[0] = enemy_y_pos[0] + enemy_size;
				if(enemy_alive[1]) enemy_y_pos[1] = enemy_y_pos[1] + enemy_size;
				if(enemy_alive[2]) enemy_y_pos[2] = enemy_y_pos[2] + enemy_size;
				if(enemy_alive[3]) enemy_y_pos[3] = enemy_y_pos[3] + enemy_size;
				if(enemy_alive[4]) enemy_y_pos[4] = enemy_y_pos[4] + enemy_size;
				if(enemy_alive[5]) enemy_y_pos[5] = enemy_y_pos[5] + enemy_size;
				if(enemy_alive[6]) enemy_y_pos[6] = enemy_y_pos[6] + enemy_size;
				if(enemy_alive[7]) enemy_y_pos[7] = enemy_y_pos[7] + enemy_size;
				if(enemy_alive[8]) enemy_y_pos[8] = enemy_y_pos[8] + enemy_size;
				if(enemy_alive[9]) enemy_y_pos[9] = enemy_y_pos[9] + enemy_size;
				if(enemy_alive[10]) enemy_y_pos[10] = enemy_y_pos[10] + enemy_size;
				if(enemy_alive[11]) enemy_y_pos[11] = enemy_y_pos[11] + enemy_size;
				if(enemy_alive[12]) enemy_y_pos[12] = enemy_y_pos[12] + enemy_size;
				if(enemy_alive[13]) enemy_y_pos[13] = enemy_y_pos[13] + enemy_size;
				if(enemy_alive[14]) enemy_y_pos[14] = enemy_y_pos[14] + enemy_size;
				if(enemy_alive[15]) enemy_y_pos[15] = enemy_y_pos[15] + enemy_size;
				if(enemy_alive[16]) enemy_y_pos[16] = enemy_y_pos[16] + enemy_size;
				if(enemy_alive[17]) enemy_y_pos[17] = enemy_y_pos[17] + enemy_size;
			end
				
			if((enemy_y_pos[0] + enemy_size > 400 && enemy_alive[0]) ||
			(enemy_y_pos[1] + enemy_size > 400 && enemy_alive[1]) ||
			(enemy_y_pos[2] + enemy_size > 400 && enemy_alive[2]) ||
			(enemy_y_pos[3] + enemy_size > 400 && enemy_alive[3]) ||
			(enemy_y_pos[4] + enemy_size > 400 && enemy_alive[4]) ||
			(enemy_y_pos[5] + enemy_size > 400 && enemy_alive[5]) ||
			(enemy_y_pos[6] + enemy_size > 400 && enemy_alive[6]) ||
			(enemy_y_pos[7] + enemy_size > 400 && enemy_alive[7]) ||
			(enemy_y_pos[8] + enemy_size > 400 && enemy_alive[8]) ||
			(enemy_y_pos[9] + enemy_size > 400 && enemy_alive[9]) ||
			(enemy_y_pos[10] + enemy_size > 400 && enemy_alive[10]) ||
			(enemy_y_pos[11] + enemy_size > 400 && enemy_alive[11]) ||
			(enemy_y_pos[12] + enemy_size > 400 && enemy_alive[12]) ||
			(enemy_y_pos[13] + enemy_size > 400 && enemy_alive[13]) ||
			(enemy_y_pos[14] + enemy_size > 400 && enemy_alive[14]) ||
			(enemy_y_pos[15] + enemy_size > 400 && enemy_alive[15]) ||
			(enemy_y_pos[16] + enemy_size > 400 && enemy_alive[16]) ||
			(enemy_y_pos[17] + enemy_size > 400 && enemy_alive[17]) 
			)
			begin
				lost = 1'b1;
			end
			
			// handling collisions - enemy-bullet
			if(
			(bullet_x <= enemy_x_pos[0] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[0]) &&
			(bullet_y <= enemy_y_pos[0] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[0])
			)
			begin
				enemy_y_pos[0] = 600;
				enemy_alive[0] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
		
			if(
			(bullet_x <= enemy_x_pos[1] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[1]) &&
			(bullet_y <= enemy_y_pos[1] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[1])
			)
			begin
				enemy_y_pos[1] = 600;
				enemy_alive[1] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[2] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[2]) &&
			(bullet_y <= enemy_y_pos[2] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[2])
			)
			begin
				enemy_y_pos[2] = 600;
				enemy_alive[2] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[3] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[3]) &&
			(bullet_y <= enemy_y_pos[3] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[3])
			)
			begin
				enemy_y_pos[3] = 600;
				enemy_alive[3] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
		
			if(
			(bullet_x <= enemy_x_pos[4] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[4]) &&
			(bullet_y <= enemy_y_pos[4] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[4])
			)
			begin
				enemy_y_pos[4] = 600;
				enemy_alive[4] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[5] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[5]) &&
			(bullet_y <= enemy_y_pos[5] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[5])
			)
			begin
				enemy_y_pos[5] = 600;
				enemy_alive[5] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[6] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[6]) &&
			(bullet_y <= enemy_y_pos[6] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[6])
			)
			begin
				enemy_y_pos[6] = 600;
				enemy_alive[6] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
		
			if(
			(bullet_x <= enemy_x_pos[7] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[7]) &&
			(bullet_y <= enemy_y_pos[7] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[7])
			)
			begin
				enemy_y_pos[7] = 600;
				enemy_alive[7] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[8] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[8]) &&
			(bullet_y <= enemy_y_pos[8] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[8])
			)
			begin
				enemy_y_pos[8] = 600;
				enemy_alive[8] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[9] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[9]) &&
			(bullet_y <= enemy_y_pos[9] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[9])
			)
			begin
				enemy_y_pos[9] = 600;
				enemy_alive[9] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
		
			if(
			(bullet_x <= enemy_x_pos[10] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[10]) &&
			(bullet_y <= enemy_y_pos[10] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[10])
			)
			begin
				enemy_y_pos[10] = 600;
				enemy_alive[10] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[11] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[11]) &&
			(bullet_y <= enemy_y_pos[11] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[11])
			)
			begin
				enemy_y_pos[11] = 600;
				enemy_alive[11] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[12] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[12]) &&
			(bullet_y <= enemy_y_pos[12] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[12])
			)
			begin
				enemy_y_pos[12] = 600;
				enemy_alive[12] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[13] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[13]) &&
			(bullet_y <= enemy_y_pos[13] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[13])
			)
			begin
				enemy_y_pos[13] = 600;
				enemy_alive[13] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[14] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[14]) &&
			(bullet_y <= enemy_y_pos[14] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[14])
			)
			begin
				enemy_y_pos[14] = 600;
				enemy_alive[14] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[15] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[15]) &&
			(bullet_y <= enemy_y_pos[15] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[15])
			)
			begin
				enemy_y_pos[15] = 600;
				enemy_alive[15] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
		
			if(
			(bullet_x <= enemy_x_pos[16] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[16]) &&
			(bullet_y <= enemy_y_pos[16] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[16])
			)
			begin
				enemy_y_pos[16] = 600;
				enemy_alive[16] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= enemy_x_pos[17] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[17]) &&
			(bullet_y <= enemy_y_pos[17] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[17])
			)
			begin
				enemy_y_pos[17] = 600;
				enemy_alive[17] = 1'b0;
				bullet_y = 0;
				points = points + 1;
				killed = killed + 1;
				bullet_free = 1'b1;
			end
			// handling collisions - obstacle-bullet
			if(
			(bullet_x <= obstacle_x_pos[0] + obstacle_x_size && bullet_x + bullet_size >= obstacle_x_pos[0]) &&
			(bullet_y <= obstacle_y_pos[0] + obstacle_y_size && bullet_y + bullet_size >= obstacle_y_pos[0]) && 
			obstacle_life[0] > 0
			)
			begin
				obstacle_life[0] = obstacle_life[0] -1;
				bullet_y = 0;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= obstacle_x_pos[1] + obstacle_x_size && bullet_x + bullet_size >= obstacle_x_pos[1]) &&
			(bullet_y <= obstacle_y_pos[1] + obstacle_y_size && bullet_y + bullet_size >= obstacle_y_pos[1]) &&
			obstacle_life[1] > 0
			)
			begin
				obstacle_life[1] = obstacle_life[1] -1;
				bullet_y = 0;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= obstacle_x_pos[2] + obstacle_x_size && bullet_x + bullet_size >= obstacle_x_pos[2]) &&
			(bullet_y <= obstacle_y_pos[2] + obstacle_y_size && bullet_y + bullet_size >= obstacle_y_pos[2]) &&
			obstacle_life[2] > 0
			)
			begin
				obstacle_life[2] = obstacle_life[2] -1;
				bullet_y = 0;
				bullet_free = 1'b1;
			end
			
			if(
			(bullet_x <= obstacle_x_pos[3] + obstacle_x_size && bullet_x + bullet_size >= obstacle_x_pos[3]) &&
			(bullet_y <= obstacle_y_pos[3] + obstacle_y_size && bullet_y + bullet_size >= obstacle_y_pos[3]) &&
			obstacle_life[3] > 0
			)
			begin
				obstacle_life[3] = obstacle_life[3] -1;
				bullet_y = 0;
				bullet_free = 1'b1;
			end
			
			
			if(killed == 18)
			begin 
				level = level + 1;
				killed = 0;
				enemy_direction = 1'b0;
				
				enemy_x_pos[0] = 200;
				enemy_y_pos[0] = 40;
				enemy_alive[0] = 1'b1;

				enemy_x_pos[1] = 260;
				enemy_y_pos[1] = 40;
				enemy_alive[1] = 1'b1;		
				
				enemy_x_pos[2] = 320;
				enemy_y_pos[2] = 40;
				enemy_alive[2] = 1'b1;

				enemy_x_pos[3] = 380;
				enemy_y_pos[3] = 40;
				enemy_alive[3] = 1'b1;	
				
				enemy_x_pos[4] = 440;
				enemy_y_pos[4] = 40;
				enemy_alive[4] = 1'b1;

				enemy_x_pos[5] = 500;
				enemy_y_pos[5] = 40;
				enemy_alive[5] = 1'b1;		
				
				enemy_x_pos[6] = 560;
				enemy_y_pos[6] = 40;
				enemy_alive[6] = 1'b1;

				enemy_x_pos[7] = 620;
				enemy_y_pos[7] = 40;
				enemy_alive[7] = 1'b1;	
				
				enemy_x_pos[8] = 680;
				enemy_y_pos[8] = 40;
				enemy_alive[8] = 1'b1;	
				
				enemy_x_pos[9] = 200;
				enemy_y_pos[9] = 100;
				enemy_alive[9] = 1'b1;

				enemy_x_pos[10] = 260;
				enemy_y_pos[10] = 100;
				enemy_alive[10] = 1'b1;		
				
				enemy_x_pos[11] = 320;
				enemy_y_pos[11] = 100;
				enemy_alive[11] = 1'b1;

				enemy_x_pos[12] = 380;
				enemy_y_pos[12] = 100;
				enemy_alive[12] = 1'b1;	
				
				enemy_x_pos[13] = 440;
				enemy_y_pos[13] = 100;
				enemy_alive[13] = 1'b1;

				enemy_x_pos[14] = 500;
				enemy_y_pos[14] = 100;
				enemy_alive[14] = 1'b1;		
				
				enemy_x_pos[15] = 560;
				enemy_y_pos[15] = 100;
				enemy_alive[15] = 1'b1;

				enemy_x_pos[16] = 620;
				enemy_y_pos[16] = 100;
				enemy_alive[16] = 1'b1;	
				
				enemy_x_pos[17] = 680;
				enemy_y_pos[17] = 100;
				enemy_alive[17] = 1'b1;	
				
				obstacle_x_pos[0] = 247;
				obstacle_y_pos[0] = 400;
				obstacle_x_pos[1] = 375;
				obstacle_y_pos[1] = 400;
				obstacle_x_pos[2] = 503;
				obstacle_y_pos[2] = 400;
				obstacle_x_pos[3] = 631;
				obstacle_y_pos[3] = 400;
				
				obstacle_life[0] = 4;
				obstacle_life[1] = 4;
				obstacle_life[2] = 4;
				obstacle_life[3] = 4;
				
				bullet_x = 0;
				bullet_y = 0;
				bullet_free = 1'b1;
				
				position_x = (640/2) + 144;
				position_y = 450;
			end
			
			//if bullet is free and space is pushed -> fire the bullet
			if(fired == 1'b1 && bullet_free == 1'b1)
			begin
				bullet_y = position_y ;
				bullet_x = position_x + bullet_size/2;
				bullet_free = 1'b0;
			end
			
			//if bullet is busy move the bullet up
			if(bullet_free == 1'b0)
				bullet_y = bullet_y - 10;
			
			//if bullet is at the top of the screen mark it as free and move into darkness 
			if(bullet_y <= 35)
			begin
				bullet_y = 0;
				bullet_free = 1'b1;
			end
		end
	end
	
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign Red = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 4'h0;
	assign Blue = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 4'h0;
	assign Green = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 4'h0;	
endmodule


module move_clk(clk, clk_move);
	input clk;
	output reg clk_move;
	reg [21:0] count;	

	always@(posedge clk)
	begin
		count <= count + 1;
		if(count == 1777777)
		begin
			clk_move <= ~clk_move;
			count <= 0;
		end	
	end
endmodule


module vga_clk(clk, clk25MHz);
	input clk; 					//50MHz clock
	output reg clk25MHz; 	//25MHz clock
	
	always@(posedge clk)
	begin
		clk25MHz <= ~clk25MHz;
	end
endmodule


module keyboard(kData, kClock, direction_x, LEDR, fired);
	input kClock, kData;
	reg [10:0] key_code;
	reg [7:0] code;
	reg [7:0] prev_code;
	integer count = 0;
	output reg [2:0] direction_x;
	output reg [9:0] LEDR;
	output reg fired;
	
	initial 
	begin
		direction_x = 0;
		fired = 1'b0;
	end

	always@(negedge kClock) 
	begin
		key_code[count] = kData;
		count = count + 1;			
		if(count == 11)
		begin
			prev_code = code;
			code = key_code[8:1];
			LEDR = code;
			count = 0;
		end
	end
	
	always@(code)
	begin
		if(prev_code == 8'hF0) // break code
		begin
			fired = 1'b0;
			direction_x = 0;
		end
		else if(code == 8'h1C) // a goes left
		begin
			direction_x = 1;
			fired = 1'b0;
		end	
		else if(code == 8'h23) // d goes right
		begin
			direction_x = 2;
			fired = 1'b0;
		end	
		else if (code == 8'h29) // space fire
		begin 
			fired = 1'b1;
		end
	end
endmodule
	