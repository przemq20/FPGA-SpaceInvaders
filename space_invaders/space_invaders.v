//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module space_invaders(

	//////////// CLOCK //////////
	input clk,

	//////////// LED //////////
	output [9:0] LEDR,
	input [1:0] KEY,
	//////////// VGA //////////
	output VGA_hSync,
	output VGA_vSync, 
	output [3:0] Red, Green, Blue,

	//////////// Keyboard //////////
	input kData, 
	input kClock 
);
	integer i;
	//vga
	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
		
	//clock
	wire clk25MHz;
	wire clk_move;
	
	//logic
	integer size_x = 20;
	integer size_y = 30;
	integer position_x = (640/2) + 144;
	integer position_y = 450;
	wire  [2:0] direction_x;
	integer direction_y = 0;
	
	// enemy	
	integer enemy_x_pos[6:0];
	integer enemy_y_pos[6:0];
	integer enemy_direction[6:0];
	reg enemy_alive[6:0];

	initial
	begin
		for(i=0;i<7;i=i+1)
		begin
			enemy_x_pos[i] = 150 + i*90;
			enemy_y_pos[i] = 40;
			enemy_direction[i] = 0;
			enemy_alive[i] = 1'b1;
		end
	end

	integer enemy_size = 20;

	//bullet
	integer bullet_x = 0;
	integer bullet_y = 0;
	integer bullet_size = 10;
	wire fired;
	integer bullet_clk = 0;
	
	reg [6:0] digit1 = 7'b0111111;
	reg [6:0] digit2 = 7'b0111111;
	integer points = 0;
	
	integer level = 1;
	integer killed = 0;
	
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
      if ((counter_y >= position_y && counter_y < position_y+size_y && counter_x >= position_x && counter_x < position_x + size_x) ||
		(counter_y >= enemy_y_pos[0] && counter_y < enemy_y_pos[0] + enemy_size && counter_x >= enemy_x_pos[0] && counter_x < enemy_x_pos[0] + enemy_size) ||
		(counter_y >= enemy_y_pos[1] && counter_y < enemy_y_pos[1] + enemy_size && counter_x >= enemy_x_pos[1] && counter_x < enemy_x_pos[1] + enemy_size) ||
		(counter_y >= enemy_y_pos[2] && counter_y < enemy_y_pos[2] + enemy_size && counter_x >= enemy_x_pos[2] && counter_x < enemy_x_pos[2] + enemy_size) ||
		(counter_y >= enemy_y_pos[3] && counter_y < enemy_y_pos[3] + enemy_size && counter_x >= enemy_x_pos[3] && counter_x < enemy_x_pos[3] + enemy_size) ||
		(counter_y >= enemy_y_pos[4] && counter_y < enemy_y_pos[4] + enemy_size && counter_x >= enemy_x_pos[4] && counter_x < enemy_x_pos[4] + enemy_size) ||
		(counter_y >= enemy_y_pos[5] && counter_y < enemy_y_pos[5] + enemy_size && counter_x >= enemy_x_pos[5] && counter_x < enemy_x_pos[5] + enemy_size) ||
		(counter_y >= enemy_y_pos[6] && counter_y < enemy_y_pos[6] + enemy_size && counter_x >= enemy_x_pos[6] && counter_x < enemy_x_pos[6] + enemy_size) ||
		(counter_y >= bullet_y && counter_y < bullet_y + bullet_size && counter_x >= bullet_x && counter_x < bullet_x + bullet_size) ||
		
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
				r_red <= 4'hF;    
				r_blue <= 4'hF;
				r_green <= 4'hF;
			end 
		else 
			begin
				r_red <= 4'h0;    
				r_blue <= 4'h0;
				r_green <= 4'h0;
			end
	end
	
	always @ (posedge clk_move)
	begin
		if(direction_x == 1)
		begin
			position_x = position_x - 10;
		end
		else if(direction_x == 2)
		begin
			position_x = position_x + 10;
		end
		
		if(position_x > 783 - size_x)
		begin
			position_x = 144;
		end
		else if(position_x < 144)
		begin
			position_x = 783 - size_x;
		end
		
		// enemy
		// enemy: move x
		for(i=0;i<7;i=i+1)
		begin
			if(enemy_direction[i] == 0) 
			begin
				enemy_x_pos[i] = enemy_x_pos[i] + (level*2) +3;
			end
			else 
			begin
				enemy_x_pos[i] = enemy_x_pos[i] - (level*2) -3;
			end
		end
		
		// enemy: move down when chaneging a direction
		for(i=0;i<7;i=i+1)
		begin
			if(enemy_x_pos[i] > 784 || enemy_x_pos[i] + enemy_size < 144)		
			begin
				enemy_direction[i] = ~enemy_direction[i];
				enemy_y_pos[i] = enemy_y_pos[i] + enemy_size + 10;
			end
			if(enemy_y_pos[i] > 400 && enemy_alive[i])
			begin
				enemy_y_pos[i] = 40;
				points = points - 10;
			end
		end
		
		// handling collisions
		for(i=0;i<7;i=i+1)
		begin
			if(
			(bullet_x <= enemy_x_pos[i] + enemy_size && bullet_x + bullet_size >= enemy_x_pos[i]) &&
			(bullet_y <= enemy_y_pos[i] + enemy_size && bullet_y + bullet_size >= enemy_y_pos[i])
			)
			begin
				enemy_y_pos[i] = 600;
				enemy_alive[i] = 1'b0;
				bullet_y = position_y ;
				bullet_x = position_x + bullet_size/2;
				points = points +1;
				killed = killed +1;
			end
		end
		
		if(killed == 7)
		begin 
			level = level + 1;
			killed = 0;
			for(i=0;i<7;i=i+1)
			begin
				enemy_x_pos[i] = 150 + i*90;
				enemy_y_pos[i] = 40;
				enemy_direction[i] = 0;
				enemy_alive[i] = 1'b1;
			end
		end
		
		////////////////////////////////////// VVV BEBLOW CODE IS TO CHANGE
		//bullet run by clock //todo: change to space
		bullet_clk = bullet_clk +1;
		if(bullet_y <= 35 ) begin // todo make sure if 30 is ok
			// todo: make sure parameters are ok
			bullet_y = position_y ;
			bullet_x = position_x + bullet_size/2;
		end
		/////////////////////////////////////// ^^^ ABOVE CODE IS TO CHANGE
		// bullet	
		if(fired == 1'b1) begin
			bullet_y = bullet_y - 5;
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
	output reg clk25MHz; 		//25MHz clock
	
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
			direction_x = 0;
		end
		else if(code == 8'h1C) // a goes left
		begin
			direction_x = 1;
		end	
		else if(code == 8'h23) // d goes right
		begin
			direction_x = 2;
		end	
		else if (code == 8'h29) // space fire (doesn't work)
		begin 
			fired = 1'b1;
		end

	end
endmodule

//module intTo7Seq(points, digit1, digit2)
//	input points;
//	output reg[6:0] digit1;
//	output reg[6:0] digit2;
//	
//	always@(points)
//	begin 
//	end
//
//endmodule

	