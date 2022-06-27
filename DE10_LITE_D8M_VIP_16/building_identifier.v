module building_identifier(
	clk,  
	white_detect,
	black_detect,
	alien_building,
	white_count,
	black_count
);
	
	input clk;   //clock
	input white_detect;
	input black_detect;//synchronous reset
	output alien_building;
	output [7:0] white_count; 
	output [7:0] black_count; //8-bit count value
	
	reg [7:0] white_count = 8'b0;
	reg [7:0] black_count = 8'b0;
	reg alien_building;

	
	always @ (posedge clk) begin
		if (white_detect || black_detect) begin
			if (white_detect) begin 
				white_count = white_count + 1;
			end
			if ((white_count >= 5) && (black_detect)) begin
				black_count = black_count + 1;
				if (black_count >= 5) begin
					alien_building = 1;
					black_count = 0;
					white_count = 0;
				end
			end
		end
	end	
			
	endmodule 
	