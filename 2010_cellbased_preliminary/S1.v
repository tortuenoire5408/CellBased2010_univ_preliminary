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
reg [1:0] k;
reg [2:0] j;
reg [2:0] cs, ns;
reg [4:0] i;
reg [7:0] mem [17:0];
//----------------------------------------------------------------------------
parameter IDLE = 3'd0,
          READ_RB1 = 3'd1,
          SEND_ADDR = 3'd2,
          SEND_DATA = 3'd3,
          PEND = 3'd4;
//----------------------------------------------------------------------------

always @(negedge clk or posedge rst) begin
      if(rst) cs <= IDLE;
      else cs <= ns;
end

always @(*) begin
      case (cs)
            IDLE: ns = READ_RB1;
            READ_RB1: begin
                  if(RB1_Q >= 0) ns = READ_RB1;
                  else ns = SEND_ADDR;
            end
            SEND_ADDR: begin
                  if(k == 2'd0) ns = SEND_DATA;
                  else ns = SEND_ADDR;
            end
            SEND_DATA: begin
                  if(i == 5'd0) ns = PEND;
                  else ns = SEND_DATA;
            end
            PEND: begin
                  if(j == 3'd7) ns = PEND;
                  else ns = SEND_ADDR;
            end
            default: ns = IDLE;
      endcase
end

// mem
always @(negedge clk or posedge rst) begin
      if(cs == READ_RB1) begin
            mem[i] <= RB1_Q;
      end
end

// RB1_RW
always @(negedge clk or posedge rst) begin
      if(rst) RB1_RW <= 1'd1;
end

// RB1_A
always @(negedge clk or posedge rst) begin
      if(rst) RB1_A <= 5'd0;
      else if(cs == READ_RB1)  RB1_A <= RB1_A + 5'd1;
end

// RB1_D
always @(*) begin
      if(cs == IDLE) RB1_D = 8'd0;
      else RB1_D = 8'd0;
end

// i
always @(negedge clk or posedge rst) begin
      if(rst) i <= 5'd0;
      else if(cs == READ_RB1) i <= i + 5'd1;
      else if(cs == SEND_ADDR) i <= (k == 2'd0) ? 5'd17 : i;
      else if(cs == SEND_DATA) i <= i - 5'd1;
end

// k
always @(negedge clk or posedge rst) begin
      if(rst) k <= 2'd2;
      else if(cs == SEND_ADDR) k <= (k == 2'd0) ? 2'd2 : k - 2'd1;
end

// sd
always @(*) begin
      if(rst) sd = 1'd0;
      else if(cs == SEND_ADDR) sd = j[k];
      else if(cs == SEND_DATA) sd = mem[i][7 - j];
      else sd = 1'd0;
end

// j
always @(negedge clk or posedge rst) begin
      if(rst) j <= 3'd0;
      else if(cs == PEND) j <= j + 3'd1;
end

// sen
always @(*) begin
      if(cs == IDLE) sen = 1'd1;
      else if(cs == SEND_ADDR || cs == SEND_DATA) sen = 1'd0;
      else sen = 1'd1;
end

//----------------------------------------------------------------------------
endmodule