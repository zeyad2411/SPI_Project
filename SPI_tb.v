module spi_tb();

  reg clk, rst_n;
  reg MOSI, SS_n;
  wire MISO;

  // Instantiate the Device Under Test (DUT)
  spi_wrapper DUT (
    .MOSI(MOSI),
    .SS_n(SS_n),
    .clk(clk),
    .rst_n(rst_n),
    .MISO(MISO)
  );

  // Clock generation
  initial begin
    clk=0;
    forever #1 clk=~clk;
  end

initial begin
rst_n=1;
MOSI=0;
SS_n=1;
   // rst_n test 
SS_n=0;
rst_n=0;
repeat(1000) begin
  MOSI=$random;
  $display("MISO=%b" , MISO);
  if(MISO != 0) begin    // we will check the internal values of rx_data and rx_valid
    $display("There is an error in the reset");
    $stop;
  end 
  $display("reset test is passed successfully");
end




end

endmodule
