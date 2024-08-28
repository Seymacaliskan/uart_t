`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 16:06:19
// Design Name: 
// Module Name: uart_rx
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

module uart_rx (
    input logic rx_en, rst, clk,
    output logic [7:0] data_out,
    output logic rx_done // iþlenen veri
);

    parameter int baudrate = 50000000 / 115200;
    parameter logic [1:0] IDLE = 2'b00;
    parameter logic [1:0] START = 2'b01;
    parameter logic [1:0] DATA = 2'b10;
    parameter logic [1:0] STOP = 2'b11;

    logic [1:0] current; // þuanki durumu tutar
    logic [3:0] bit_counter; // alýnan bit sayýsýný sayar
    logic [8:0] serial_data; // alýnan seri veriyi tutan kaydýrma kaydý
    logic [15:0] deb_counter;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            current <= IDLE;
            bit_counter <= 4'd0;
            serial_data <= 9'd0;
            deb_counter <= 16'd0;
            rx_done <= 1'b0;
        end else begin
            case (current)
                IDLE: begin
                    rx_done <= 1'b0;
                    if (!rx_en) begin
                        current <= START;
                        bit_counter <= 4'd0;
                        deb_counter <= 16'd0;
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
                    deb_counter <= deb_counter + 1;
                    if (deb_counter == baudrate) begin
                        bit_counter <= bit_counter + 1;
                        deb_counter <= 16'd0;
                        serial_data <= {rx_en, serial_data[8:1]}; // burada kaydýrma iþlemi yapýlýr
                        if (bit_counter == 4'd8) begin
                            current <= STOP;
                            bit_counter <= 4'd0;
                        end
                    end
                end
                STOP: begin
                    data_out <= serial_data[8:1];
                    rx_done <= 1'b1;
                    current <= IDLE;
                    deb_counter <= 16'd0;
                end
            endcase
        end
    end
endmodule


