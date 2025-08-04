module SPI_Slave (
MOSI,
MISO,
SS_n,
clk,
rst_n,
rx_data,
rx_valid,
tx_data,
tx_valid
);
// inputs 
input clk , rst_n , MOSI , SS_n , tx_valid;
input [7:0] tx_data;

// outputs
output reg rx_valid , MISO ;
output  reg [9:0] rx_data;

// current state an next state
  reg [2:0] cs,ns;

// internal wires and signals
  reg [3:0] bit_count=3'b000;   // Counts up to 10  
  reg ADDR_DATA=0;             //to check whether we received a addres or not



// SPI FSM states
parameter IDLE       = 3'b000;
parameter CHK_CMD    = 3'b001;
parameter WRITE      = 3'b010;
parameter READ_ADDR  = 3'b011;
parameter READ_DATA  = 3'b100;

//always 


// Next state logic
always @ (*) begin
  case (cs)
    IDLE: begin
      if (SS_n == 1) begin
        ns <= IDLE;
      end
      else if (SS_n == 0) begin
        ns <= CHK_CMD;
      end
    end 
    CHK_CMD: begin
    
    end 
    WRITE: begin
      
    end 
    READ_ADDR: begin
      
    end 
    READ_DATA: begin
      
    end 
    default: ns=IDLE;
  endcase
end

// State memory 
always @ (posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    cs <= IDLE;
  end
  else 
  cs <= ns;
end

// output logic 
always @(posedge clk) begin

end


endmodule
