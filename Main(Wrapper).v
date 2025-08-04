module spi_wrapper(
    input   MOSI,
            SS_n,
            clk,
            rst_n;
    output  MISO;
);
    wire rx_valid, tx_valid;
    wire [9 : 0]    rx_data;
    wire [7 : 0]    tx_data;

    SPI_Slave slave(.MOSI(MOSI),
                    .MISO(MISO),
                    .SS_n(SS_n),
                    .clk(clk),
                    .rst_n(rst_n),
                    .rx_data(rx_data),
                    .rx_valid(rx_valid),
                    .tx_data(tx_data),
                    .tx_valid(tx_valid));
                    
    RAM ram(.din(rx_data),
            .rx_valid(rx_valid),
            .dout(tx_data),
            .tx_valid(tx_valid),
            .clk(clk),
            .rst_n(rst_n));

endmodule
