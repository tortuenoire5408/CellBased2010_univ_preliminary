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
reg [2:0] addr;
reg [3:0] k;
reg [4:0] i;
reg [17:0] data;
reg [1:0] state;
//----------------------------------------------------------------------------
parameter receive_data = 2'b00, write_RB2 = 2'b01, finish = 2'b10;
//----------------------------------------------------------------------------
always@(posedge clk or posedge rst) begin
	if(rst) begin
		RB2_RW = 1;
		RB2_A = 0; RB2_D = 0; S2_done = 0;

		state = receive_data;
		i = 0; k = 0;
	end else begin
		case(state)
			receive_data: begin
				if(!sen) begin
					RB2_RW = 1;
					if(i >= 3) begin
						data[20 - i] = sd;
						i = i + 1;
						if(i == 20) state = write_RB2;
						else state = receive_data;
					end else begin
						addr[2 - i] = sd;
						i = i + 1;
						state = receive_data;
					end
				end
			end
			write_RB2: begin
				if(!sen) begin
					RB2_RW = 0;
					data[20 - i] = sd;
					RB2_A = addr;
					RB2_D = data;
					k = k + 1;

					if(k == 8) begin
						state = finish;
						k = 0;
					end else begin
						state = receive_data;
						i = 0;
					end
				end
			end
			finish: begin
				if(RB2_Q == RB2_D) begin
					RB2_RW = 1;
					S2_done = 1;
				end
			end
		endcase
	end
end
//----------------------------------------------------------------------------
endmodule
