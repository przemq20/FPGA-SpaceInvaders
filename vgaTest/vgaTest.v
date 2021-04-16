module vgaTest(
	input clk,
	output VGA_hSync,
	output VGA_vSync, 
	output [3:0] Red, Green, Blue
);
	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
	reg reset = 0;  // for PLL
	wire clk25MHz;
	
	integer size_x = 30;
	integer size_y = 30;
	integer position_x = 360;
	integer position_y = 200;
	integer waitt = 1000000;
	integer counter = 0;
	
	// clk divider 50 MHz to 25 MHz
	clock_devider clock_devider1(
		.areset(reset),
		.inclk0(clk),
		.c0(clk25MHz),
		.locked()
		);  
	
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

	always @ (posedge clk25MHz)
	begin
      if (counter_y >= position_y && counter_y < position_y+size_y)
      begin
         if (counter_x >= position_x && counter_x < position_x + size_x)
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
		else 
		begin
			r_red <= 4'h0;    
			r_blue <= 4'h0;
			r_green <= 4'h0;
		end		
	end

	always @ (posedge clk25MHz)
	begin
		counter <= counter +1;
		if(counter > waitt)
		begin
			position_y <= ((position_y + 1) % (514 - size_y));
			position_x <= ((position_x + 1) % (783 - size_x)) ;
			counter <= 0;
			if(position_y < 35)
			begin
				position_y <= 35;
			end
			if(position_x < 144)
			begin
				position_x <= 144;
			end
		end
		
	end
	
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign Red = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 4'h0;
	assign Blue = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 4'h0;
	assign Green = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 4'h0;	
endmodule