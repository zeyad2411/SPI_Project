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
    clk = 0;
    forever #1 clk = ~clk;
  end

  reg error_found = 0;
  integer j;
  reg [9:0] tx_packet;
  reg [7:0] test_address = 8'hA5;
  reg [7:0] test_data    = 8'h3C;

  // Send serial bits MSB-first on MOSI
  task send_packet(input [9:0] data);
    begin
      SS_n = 0;
      for (j = 9; j >= 0; j = j - 1) begin
        @(negedge clk);
        MOSI = data[j];
      end
      @(negedge clk); // Final clock after last bit
      SS_n = 1;
    end
  endtask

  initial begin
    // Init
    rst_n = 1;
    MOSI  = 0;
    SS_n  = 1;

    // Reset test
    SS_n = 0;
    rst_n = 0;
    repeat(1000) begin
      @(negedge clk);
      MOSI = $random;
      if (MISO !== 0) begin
        $display("Error during reset: MISO = %b", MISO);
        error_found = 1;
      end
    end
    SS_n = 1;

    if (!error_found)
      $display("Reset test passed successfully.");
    else
      $stop;

    // Deassert reset
    rst_n = 1;
    MOSI = 0;
    #5;

    // ==== WRITE Address ====
    tx_packet = {2'b00, test_address};  // 10-bit packet
    $display("Sending write address: %h", test_address);
    send_packet(tx_packet);

    // ==== WRITE Data ====
    tx_packet = {2'b01, test_data};
    $display("Sending write data: %h", test_data);
    send_packet(tx_packet);

    // ==== READ Address ====
    tx_packet = {2'b10, test_address};
    $display("Sending read address: %h", test_address);
    send_packet(tx_packet);

    // ==== READ Data ====
    tx_packet = {2'b11, 8'h00};  // Data ignored
    $display("Sending read command, expecting to receive %h", test_data);
    send_packet(tx_packet);

    // Wait a few clocks to observe MISO output
    repeat(16) begin
      @(negedge clk);
      $display("MISO = %b", MISO);
    end

    $display("Test completed.");
    $stop;
  end

endmodule
