module SPI_Slave (
input MOSI     ,
      tx_valid ,
      SS_n     ,
      clk      ,
      rst_n    ,
input [7:0] tx_data , 
output reg  MISO     ,
            rx_valid ,
output reg [9:0]  rx_data  
);

// States:
parameter IDLE      = 3'b000;
parameter CHK_CMD   = 3'b001;
parameter WRITE     = 3'b010;
parameter READ_DATA = 3'b011;
parameter READ_ADD  = 3'b100;

// current and next states:
reg [2:0] cs , ns ;


// internal signals: 
reg ADD_or_DATA;// if 0 -> ADD , if 1 ->DATA
reg [3:0] counter1; // to handle the SERIAL to PARALLEL 
reg [2:0] counter2; // to handle the PARALLEL to SERIAL
reg [9:0] internal_data; // to take the data before it's loaded to the rx_data

//state memory 
always @(posedge clk)
begin
    if(~rst_n) 
        cs <= IDLE;
    else 
        cs <= ns ;
end


// Next state logic:
always @(*) begin
  case (cs)
    IDLE: begin
    if (SS_n) begin
        ns = IDLE;
    end
    else begin
      ns = CHK_CMD;
    end
    end 

    CHK_CMD: begin
        if (SS_n) begin
          ns = IDLE;
        end
        else begin
      case (MOSI)
       0: begin
         ns = WRITE;
       end

       1: begin
      case (ADD_or_DATA)
        0: begin
          ns = READ_ADD;
        end 
        1: begin
          ns = READ_DATA;
        end
      endcase
       end 
      endcase
        end
    end 
    WRITE: begin
      if (SS_n || (counter1 == 4'b1111)) begin
        ns = IDLE;
      end
      else
        ns = WRITE;
    end 
    READ_ADD: begin
       if (SS_n || (counter1 == 4'b1111)) begin
        ns = IDLE;
      end
      else
        ns = READ_ADD;
    end 
    READ_DATA: begin
       if (SS_n) begin
        ns = IDLE;
      end
      else
        ns = READ_DATA;
    end 
  endcase
end

// Output logic:
    always @(posedge clk) begin
      if (~rst_n) begin
        rx_data <= 8'b0;
        rx_valid <= 0;
        ADD_or_DATA <= 0; //reading the addres first is the default
        MISO <= 0; 
      end
      else begin
        // handling the outputs & signals in the IDLE state
        if (cs == IDLE) begin
          counter1 <= 4'b1001; // to start sending by the MSB
          counter2 <= 3'b111; // to start receiving by the MSB
          internal_data <= 10'b0; //initilization with zeros
          rx_valid <= 0;
        end

        // handling the outputs in the WRITE state
       if (cs == WRITE) begin // conversion from serial to parallel happens here
         if (counter1 >= 0 ) begin
           internal_data[counter1] <= MOSI;
           counter1 = counter1 - 1;
         end
         if (counter1 == 4'b1111) begin // if counter1=-1 (4'b1111) means that the conversion process is done
           rx_data <= internal_data;
           rx_valid <= 1;
         end
       end

        // handling the outputs in the READ_ADD state
        if (cs == READ_ADD) begin //same as WRITE state
          if (counter1 >= 0 ) begin
           internal_data[counter1] <= MOSI;
           counter1 <= counter1 - 1;
         end
         if (counter1 == 4'b1111) begin // if counter1=-1 (4'b1111) means that the conversion process is done
           rx_data <= internal_data;
           rx_valid <= 1;
         end
        end
 
        // handling the outputs in the READ_DATA state
        if (cs == READ_DATA) begin
          if (counter1 >= 0 ) begin
           internal_data[counter1] <= MOSI;
           counter1 = counter1 - 1;
         end
         if (counter1 == 4'b1111) begin // if counter1=-1 (4'b1111) means that the conversion process is done
           rx_data <= internal_data;
           rx_valid <= 1;
           counter1 <= 9 ; //only and only in this case we will reset the counter as we won't go back to the IDLE state until the process ends
           if (rx_valid ==1 ) rx_valid <= 0;
         end 
     // now the RAM knows that i will read data from it 
     // RAM now send the data on the tx_data 
    if (tx_valid && (counter2 >= 0)) begin
      MISO <= tx_data[counter2]; // sending the data and converting it from parallel to series
      counter2 <= counter2 -1 ;
    end
    if (counter2 == 3'b111) begin 
      ADD_or_DATA <= 0; //now i want another address to read the data from
    end
        end
      end
    end
endmodule