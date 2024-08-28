`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 16:06:33
// Design Name: 
// Module Name: uart_tx
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

module uart_tx(
    input logic full, empty,
    input logic clk, rst, // x = tetikleyici sinyal
    output logic tx
);

    parameter int baudrate = 50000000 / 115200;
    parameter logic [1:0] IDLE = 2'b00;
    parameter logic [1:0] START = 2'b01;
    parameter logic [1:0] DATA = 2'b10;
    parameter logic [1:0] STOP = 2'b11;

    logic [1:0] current; // mevcut durumu tutar
    logic [3:0] bit_counter; // bitlerin sayýsýný takip eder
    logic [8:0] serial_data;  // gönderilecek veriyi tutar
    logic [15:0] deb_counter;
    
    logic full_pre, empty_pre;
    logic [7:0] x;
    logic f, e;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            full_pre <= 1'b0;
            empty_pre <= 1'b0;
        end else begin
            full_pre <= full;
            empty_pre <= empty;
            if (!full_pre && full) begin
                x <= 8'b0110_0110;  // ASCII F
                f <= 1'b1;
            end else if (!empty_pre && empty) begin
                x <= 8'b0110_0101;  // ASCII E
                e <= 1'b1;
            end else begin
                f <= 1'b0;
                e <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            current <= IDLE;
            deb_counter <= 16'b0;
            bit_counter <= 4'd0;
        end else begin
            case (current)
                IDLE: begin
                    tx <= 1'b1;
                    if (f) begin
                        tx <= 1'b0;
                        serial_data <= x;
                        current <= START;
                        bit_counter <= 4'd0;
                    end else if (e) begin
                        tx <= 1'b0;
                        serial_data <= x;
                        current <= START;
                        bit_counter <= 4'd0;
                    end
                end
                START: begin
                    deb_counter <= deb_counter + 1;
                    if (deb_counter == (baudrate >> 1)) begin
                        deb_counter <= 16'd0;
                        current <= DATA;
                    end
                end
                DATA: begin
                    tx <= serial_data[0];
                    deb_counter <= deb_counter + 1;
                    if (deb_counter == baudrate) begin
                        deb_counter <= 16'd0;
                        bit_counter <= bit_counter + 1;
                        serial_data <= serial_data[8:1];
                        if (bit_counter == 4'd8) begin
                            current <= IDLE;
                            bit_counter <= 4'd0;
                        end
                    end
                end
                STOP: begin
                    deb_counter <= deb_counter + 1;
                    if (deb_counter == baudrate) begin
                        deb_counter <= 16'd0;
                        current <= IDLE;
                        tx <= 1'b0;
                        bit_counter <= 4'd0;
                    end
                end
            endcase
        end
    end
endmodule

