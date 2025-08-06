module RAM (
  din,
  clk,
  rst_n,
  rx_valid,
  dout,
  tx_valid
);
  parameter MEM_WIDTH = 8;
  parameter MEM_DEPTH = 256;
  parameter ADDR_SIZE = 8;

  input [MEM_WIDTH + 1 : 0] din;
  input clk, rst_n, rx_valid;
  output reg [MEM_WIDTH - 1 : 0] dout;     
  output reg tx_valid;                     

  reg [MEM_WIDTH - 1 : 0] mem [MEM_DEPTH - 1 : 0]; 

  reg [ADDR_SIZE-1:0] addr_rd, addr_wr;

  always @(posedge clk) begin
    if (rst_n == 0) begin
      dout <= 8'b0;
      tx_valid <= 0;
      addr_rd <= 8'b0;
      addr_wr <= 8'b0;
    end
    else begin
      case (din[9])
        0: begin
          if (rx_valid == 1) begin
            case (din[8])
              0: begin
                addr_wr <= din[7:0];  //write address
                tx_valid <= 0;
              end
              1: begin
                mem[addr_wr] <= din[7:0];
                tx_valid <= 0;
              end
            endcase
          end
        end

        1: begin
          if (rx_valid == 1) begin
            case (din[8])
              0: begin
                addr_rd <= din[7:0];
                tx_valid <= 0;
              end
              1: begin
                dout <= mem[addr_rd];
                tx_valid <= 1;
              end
            endcase
          end
        end
      endcase
    end
  end
endmodule
