module S2(clk, rst, S2_done, RB2_RW, RB2_A, RB2_D, RB2_Q, sen, sd);
input clk, rst;
input sen, sd;
input [17:0] RB2_Q;
output S2_done, RB2_RW;
output [2:0] RB2_A;
output [17:0] RB2_D;
//----------------------------------------------------------------------------
reg S2_done, RB2_RW;
reg [2:0] RB2_A;
reg [17:0] RB2_D;
//----------------------------------------------------------------------------
reg [2:0] cs, ns;
reg [2:0] addr;
reg [3:0] k;
reg [4:0] i;
reg [17:0] data;
//----------------------------------------------------------------------------
parameter IDLE = 3'd0,
          GET_ADDR = 3'd1,
		  GET_DATA = 3'd2,
          SAVE_DATA = 3'd3,
		  DONE = 3'd4;
//----------------------------------------------------------------------------

always@(posedge clk or posedge rst) begin
	if(rst) cs <= IDLE;
	else cs <= ns;
end

always@(*) begin
	case (cs)
		IDLE: begin
			if(sen == 1'd0) ns = GET_ADDR;
			else ns = IDLE;
		end
		GET_ADDR: begin
			if(i < 5'd3) ns = GET_ADDR;
			else ns = GET_DATA;
		end
		GET_DATA: begin
			if(i < 5'd21) ns = GET_DATA;
			else ns = SAVE_DATA;
		end
		SAVE_DATA: begin
			if(k == 4'd7) ns = DONE;
			else ns = GET_ADDR;
		end
		DONE: ns = IDLE;
		default: ns = IDLE;
	endcase
end

//addr
always @(posedge clk or posedge rst) begin
      if(ns == GET_ADDR) addr[2 - i] <= sd;
end

//data
always @(posedge clk or posedge rst) begin
      if(ns == GET_DATA) data[20 - i] <= sd;
end

// RB2_RW
always @(*) begin
      if(rst) RB2_RW = 1'd1;
      else if(cs == SAVE_DATA) RB2_RW = 1'd0;
	  else RB2_RW = 1'd1;
end

// RB2_A
always @(*) begin
      if(rst) RB2_A = 3'd0;
      else if(cs == SAVE_DATA) RB2_A = addr;
	  else RB2_A = 3'd0;
end

// RB2_D
always @(*) begin
      if(rst) RB2_D = 0;
      else if(cs == SAVE_DATA) RB2_D = data;
	  else RB2_D = 0;
end

// S2_done
always @(*) begin
      if(rst) S2_done = 1'd0;
      else if(cs == DONE) S2_done = 1'd1;
	  else S2_done = 1'd0;
end

// i
always @(posedge clk or posedge rst) begin
      if(rst) i <= 5'd0;
      else if(ns == GET_ADDR || ns == GET_DATA) i <= i + 5'd1;
      else if(ns == SAVE_DATA) i <= 5'd0;
end

// k
always @(posedge clk or posedge rst) begin
      if(rst) k <= 4'd0;
      else if(cs == SAVE_DATA) k <= k + 4'd1;
end

//----------------------------------------------------------------------------
endmodule
