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
  reg [3:0] bit_count = 3'b000;   // Counts up to 10  
  reg ADDR_DATA = 0;             //to check whether we received a addres or not
  reg [9:0] shift_reg;
  reg receiving;

  // SPI FSM states
  parameter IDLE       = 3'b000;
  parameter CHK_CMD    = 3'b001;
  parameter WRITE      = 3'b010;
  parameter READ_ADDR  = 3'b011;
  parameter READ_DATA  = 3'b100;

  // ADDR_DATA Logic
  always @(*) begin
    if(cs == READ_ADD)
      ADDR_DATA = 1;
    else
      ADDR_DATA = 0;
  end

      always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= 0;
            shift_reg <= 10'b0;
            rx_valid <= 0;
            receiving <= 0;
        end
        else begin
            rx_valid <= 0;

            if (!SS_n && !receiving) begin
                // begin new reception
                receiving <= 1;
                bit_count <= 0;
            end
            else if (receiving) begin
                bit_count <= bit_count + 1;

                if (bit_count > 0 && bit_count <= 10) begin
                    // shift in the MOSI bit
                    shift_reg <= {MOSI, shift_reg[9:1]}; // MSB-first
                end

                if (bit_count == 10) begin
                    rx_data <= shift_reg;
                    rx_valid <= 1;
                    receiving <= 0;
                end
            end
        end
      end

  // Next state logic
  always @ (cs, SS_n, MOSI) begin
    case (cs)
      IDLE: begin
        if (SS_n == 1) begin
          ns = IDLE;
        end
        else if (SS_n == 0) begin
          ns = CHK_CMD;
        end
      end 
      CHK_CMD: begin
        case(SS_n)
        //! Could need to add logic of MOSI Firt Bit
          0:  case(MOSI)
                1:  case(ADDR_DATA)
                      0: ns = READ_ADD;
                      1: ns = READ_DATA;
                    endcase
                0:  ns = WRITE;
              endcase
          1:  ns = IDLE;
        endcase
      end
      WRITE: begin
        //! Could need to add RX_Valid
        case(SS_n)
          0: ns = WRITE;
          1: ns = IDLE;
        endcase
      end 
      READ_ADDR: begin
        case(SS_n)
          0: ns = READ_ADDR;
          1: ns = IDLE;
        endcase
      end 
      READ_DATA: begin
        case(SS_n)
          0: ns = READ_DATA;
          1: ns = IDLE;
        endcase
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
  always @(*) begin

  end

endmodule
