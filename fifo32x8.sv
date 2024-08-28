`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 16:06:48
// Design Name: 
// Module Name: fifo32x8
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

module Fifo(
    input logic rst,
    input logic clk,
    input logic rd_en,
    input logic wr_en,
    input logic [7:0] fifo_data_in,
    output logic [7:0] data_out,
    output logic full,
    output logic empty
);

    logic [4:0] read, write;  // 5 bit geniþlikte adresleme, 32 giriþ için
    logic [7:0] memory [31:0];  // 32x8'lik hafýza
    logic deb_write;
    logic deb_read, control_write, control_read;

    always_ff @(posedge clk) begin
        deb_write <= wr_en;
        deb_read  <= rd_en;
        if (wr_en == 1'b0 && deb_write == 1'b1) begin
            control_write <= 1'b1;
        end else if (rd_en == 1'b0 && deb_read == 1'b1) begin
            control_read <= 1'b1;
        end else begin
            control_write <= 1'b0;
            control_read <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst) begin
            write <= 5'd0;
            read <= 5'd0;
        end else begin
            if (control_write && !full) begin
                memory[write % 32] <= fifo_data_in;
                write <= write + 1;
            end else if (control_read && !empty) begin
                data_out <= memory[read % 32];
                read <= read + 1;
            end
        end
    end

    assign full = (write - read == 5'b10000);  // 32 eleman için tam doluluk kontrolü
    assign empty = (read == write);

endmodule
