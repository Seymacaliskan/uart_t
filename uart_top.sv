`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 16:14:48
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module uart (
    input logic rst,
    input logic clk,
    input logic rd_en,
    input logic rx,
    output logic full,
    output logic empty,
    output logic [7:0] fifo_data_out,
    output logic tx
);

    logic rx_done;
    logic [7:0] rx_data_out;
    logic [7:0] tx_in;

    // UART RX modülü instansý
    uart_rx u_rx (
        .clk(clk),
        .rst(rst),
        .rx_en(rx),
        .data_out(rx_data_out),
        .rx_done(rx_done)
    );

    // FIFO modülü instansý
    Fifo f_fifo (
        .rst(rst),
        .clk(clk),
        .wr_en(rx_done),
        .rd_en(rd_en),
        .fifo_data_in(rx_data_out),
        .data_out(fifo_data_out),
        .full(full),
        .empty(empty)
    );

    // UART TX modülü instansý
    uart_tx u_tx (
        .clk(clk),
        .rst(rst),
        .full(full),
        .empty(empty),
        .tx(tx)
    );

endmodule

