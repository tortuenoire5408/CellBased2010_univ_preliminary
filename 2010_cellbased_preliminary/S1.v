module S1(clk, rst, RB1_RW, RB1_A, RB1_D, RB1_Q, sen, sd);
input clk, rst;
input [7:0] RB1_Q;
output RB1_RW;
output [4:0] RB1_A;
output [7:0] RB1_D;
output sen, sd;

`define VCD
//----------------------------------------------------------------------------
reg RB1_RW;
reg [4:0] RB1_A;
reg [7:0] RB1_D;
reg sen, sd;
//----------------------------------------------------------------------------
reg [1:0] k, state;
reg [2:0] j;
reg [4:0] i;
reg [7:0] mem [17:0];
//----------------------------------------------------------------------------
parameter read_RB1 = 2'b00, send_addr = 2'b01, send_data = 2'b10, pending = 2'b11;
//----------------------------------------------------------------------------
always@(negedge clk or posedge rst) begin
      if(rst) begin
            RB1_RW = 1; sen = 1;
            RB1_A = 0; RB1_D = 0; sd = 0;

            i = 0; j = 0; k = 2; state = read_RB1;
      end else begin
            case(state)
                  read_RB1: begin
                        if(RB1_Q >= 0) begin
                              mem[i] = RB1_Q;
                              i = i + 1;
                              RB1_A = i;
                              state = read_RB1;
                        end else state = send_addr;
                  end
                  send_addr: begin
                        sen = 0;
                        if(k == 0) begin
                              sd = j[k];
                              i = 17;
                              k = 2;
                              state = send_data;
                        end else begin
                              sd = j[k];
                              k = k - 1;
                              state = send_addr;
                        end
                  end
                  send_data: begin
                        sen = 0;
                        sd = mem[i][7 - j];
                        if(i == 0) state = pending;
                        else begin
                              i = i - 1;
                              state = send_data;
                        end
                  end
                  pending: begin
                        sen = 1;
                        if(j == 7) begin
                              state = pending;
                        end else begin
                              j = j + 1;
                              state = send_addr;
                        end

                  end
            endcase
      end
end
//----------------------------------------------------------------------------
endmodule
