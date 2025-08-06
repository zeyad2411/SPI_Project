module SPI_tb();

parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;
reg clk, SS_n, MOSI, rst_n;
wire MISO;

SPI_Wrapper DUT (clk, SS_n, MOSI, rst_n, MISO);

// Clock generation - 50MHz clock (20ns period)
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

initial begin
    //================================ Test Case 1 ================================//
    // Initialize system with reset
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
    SS_n = 0; // Activate slave - enter CHK_CMD state
    
    // Phase 1: Send write address command
    #20 MOSI = 0; // Command bit: 0 indicates write operation
    #20 MOSI = 0; // Address/Data selector
    #20 MOSI = 0; // Command complete: 2'b00 = write address
    
    // Transmit target address: 8'b1010_0101 (0xA5)
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    // Address transmission complete
    #20 SS_n = 1; // Deactivate slave - return to IDLE
    #60; // Inter-transaction delay
    
    // Phase 2: Send write data command
    SS_n = 0; // Reactivate slave
    #20 MOSI = 0; // Command bit: 0 for write operation
    #20 MOSI = 0; // Address/Data selector
    #20 MOSI = 1; // Command complete: 2'b01 = write data
    
    // Generate pseudo-random 8-bit data pattern
    repeat(8) begin
        #20 MOSI = $random;
    end
    #20 SS_n = 1; // Complete write data transaction
    #60; // Wait before next operation
    
    // Phase 3: Send read address command
    SS_n = 0; // Begin new transaction
    #20 MOSI = 1; // Command bit: 1 indicates read operation
    #20 MOSI = 1; // Address/Data selector
    #20 MOSI = 0; // Command complete: 2'b10 = read address
    
    // Specify read address: 8'b1010_0101 (same as write address)
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    // Read address setup complete
    #20 SS_n = 1; // End address phase
    #60; // Transition delay
    
    // Phase 4: Execute read data command
    SS_n = 0; // Start read data phase
    #20 MOSI = 1; // Command bit: 1 for read operation
    #20 MOSI = 1; // Address/Data selector
    #20 MOSI = 1; // Command complete: 2'b11 = read data
    
    // Send dummy bits (ignored during read operation)
    repeat(8) begin
        #20 MOSI = $random;
    end
    #200 SS_n = 1; // Extended time for complete data serialization (tx_valid + 8 data bits)
    #60; // Post-transaction settling time
    
    //================================ Test Case 2 ================================//
    
    // System reset for clean start
    rst_n = 0;
    #20 rst_n = 1;
    SS_n = 0; // Enter active state
    
    // Phase 1: Write address setup
    #20 MOSI = 0; // Write command indicator
    #20 MOSI = 0; // Address/Data mode
    #20 MOSI = 0; // Full command: 2'b00 = address write
    
    // Target address: 8'b0110_1001 (0x69)
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 0;
    #20 MOSI = 1;
    // Address programming finished
    #20 SS_n = 1; // Terminate address write
    #60; // Preparation time for next phase
    
    // Phase 2: Write data payload
    SS_n = 0; // Initiate data write
    #20 MOSI = 0; // Write operation flag
    #20 MOSI = 0; // Address/Data selector
    #20 MOSI = 1; // Command completion: 2'b01 = data write
    
    // Send fixed pattern: all ones (8'b1111_1111)
    repeat(8) begin
        #20 MOSI = 1;
    end
    #20 SS_n = 1; // Conclude data write operation
    #60; // Inter-phase delay
    
    // Phase 3: Configure read address
    SS_n = 0; // Begin read address setup
    #20 MOSI = 1; // Read command flag
    #20 MOSI = 1; // Address/Data selector
    #20 MOSI = 0; // Command finalization: 2'b10 = read address
    
    // Read from address: 8'b0110_1001 (matching write address)
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 1;
    #20 MOSI = 0;
    #20 MOSI = 0;
    #20 MOSI = 1;
    // Read address configuration done
    #20 SS_n = 1; // Exit address setup
    #60; // Stabilization period
    
    // Phase 4: Perform data read
    SS_n = 0; // Start read data sequence
    #20 MOSI = 1; // Read operation identifier
    #20 MOSI = 1; // Address/Data selector
    #20 MOSI = 1; // Command execution: 2'b11 = data read
    
    // Transmit don't-care bits during read
    repeat(8) begin
        #20 MOSI = $random;
    end
    #200 SS_n = 1; // Allow full serialization cycle completion
    #60; // Final settling time
    
    $display("SPI testbench execution completed successfully");
    $stop;
end

endmodule