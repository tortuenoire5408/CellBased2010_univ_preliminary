module S2(clk, rst, S2_done, RB2_RW, RB2_A, RB2_D, RB2_Q, sen, sd);
input clk, rst;
input sen, sd;
input [17:0] RB2_Q;
output S2_done, RB2_RW;
output [2:0] RB2_A;
output [17:0] RB2_D;
//----------------------------------------------------------------------------
reg S2_done, RB2_RW, finish_sign;
reg [2:0] RB2_A;
reg [17:0] RB2_D;
//----------------------------------------------------------------------------
reg [2:0] addr;
reg [3:0] k;
reg [4:0] i;
reg [17:0] data;
//----------------------------------------------------------------------------
always@(posedge clk or posedge rst) begin
	if(rst) begin
		RB2_RW = 1;
		RB2_A = 0; RB2_D = 0; S2_done = 0;

		i = 0; k = 0; finish_sign = 0;
	end else begin
		if(!sen) begin
			RB2_RW = 1;
			if(i >= 3) begin
				data[20 - i] = sd;
				i = i + 1;
				if(i == 21) begin
					RB2_RW = 0;
					RB2_A = addr;
					RB2_D = data;
					k = k + 1;
					i = 0;
					if(k == 8) begin
						finish_sign = 1;
					end
				end
			end else begin
				addr[2 - i] = sd;
				i = i + 1;
			end
		end else begin
			if(finish_sign && RB2_Q == RB2_D) begin
				S2_done = 1;
			end
		end
	end
end
//----------------------------------------------------------------------------
endmodule
