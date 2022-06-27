module rgb2hsv( //RGB -> HSV conversion module
	input clk,
   	input wire [7:0] r,
   	input wire [7:0] g,
   	input wire [7:0] b,
	input wire in_valid,

  	output reg [7:0] h, //HSV output values
   	output reg [7:0] s,
   	output reg [7:0] v
);

//instantiate intermediate variables used in conversion
reg[7:0] cmax, cmin, cmid, delta, addon, num; //max(R, G, B
reg[17:0] hue_div_num, k_num; 
wire[17:0] hue_div_quo, hue_div_rem;  
reg [15:0] s_num;  
reg [7:0] s_denom;
wire[7:0]s_quo, s_rem, k_quo, k_rem;


always @(*) begin
	if((r >= g) && (r >= b)) begin //if R is biggest
		cmax = r;
		if(g >= b) begin
			cmin = b;
			cmid = g;
		end
		else begin
			cmin = g;
			cmid = b;
		end
	end

	else if((g >= r) && (g >= b)) begin //if G is biggest
		cmax = g;		  
		addon = 8'b01010101; //85
		if(r >= b) begin
			cmin = b;
			cmid = r;
		end
		else begin
			cmin = r;
			cmid = b;
		end
	end

	else if((b >= r) && (b >= g)) begin //if B is biggest
		cmax = b;
		addon = 8'b10101011; //171
		if(r >= g) begin
			cmin = g;
			cmid = r;
		end
		else begin
			cmin = r;
			cmid = g;
		end
	end

	delta = cmax - cmin;
	v = cmax; //compute value (V)
	s_num = 8'b11111111 * delta; //255 * (max - min)
	s_denom = cmax;
	hue_div_num = (cmid - cmin) * 1000; //scale by 1000 to conserve decimals
	k_num = hue_div_quo * 18'b101011; //multiply by 43
end

div_delta first_hue_divider(
	.clken(in_valid),
	.clock(clk),
	.denom(delta),
	.numer(hue_div_num),
	.quotient(hue_div_quo),
	.remain(hue_div_rem)
);

newdiv sat_divider(
	.clken(in_valid),
	.clock(clk),
	.denom(s_denom),
	.numer(s_num),
	.quotient(s_quo),
	.remain(s_rem)
);
	
div_k second_hue_divider(
	.clken(in_valid),
	.clock(clk),
	.denom(10'b1111101000),
	.numer(k_num),
	.quotient(k_quo),
	.remain(k_rem)
);
	 
	 
//calculate hue (H)
always @(*) begin
	
	if(delta == 0) begin //if delta = 0
		h = 8'b0;
		s = 8'b0;
	end

	else if(cmax == r) begin //if R is max
		if((cmid - cmin) == delta) begin //when fraction (mid - cmin)/delta = 1
			num = 1;
			if(b > g) begin //adjustment for negative
				num = 5;
			end
			num = 8'b00101011 * num; //multiply by 43
			h = num;
			s = s_quo;
		end
		else begin
			h = k_quo;
			s = s_quo;
		end
	end
	
	else begin
		h = k_quo + addon;
		s = s_quo;
	end
end

endmodule 