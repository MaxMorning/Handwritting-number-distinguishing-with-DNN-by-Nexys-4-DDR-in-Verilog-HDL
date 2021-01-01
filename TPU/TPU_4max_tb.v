`timescale 1ns / 1ps

module TPU_4max_tb;

    reg [2 * 2 * 8 - 1:0] data_in;

    wire [7:0] data_max;

    max_in_4 inst(
        .data_in(data_in),
        .data_max(data_max)
    );
    initial begin
        data_in = {
            8'b10000000,
            8'b01010101,
            8'b10101000,
            8'b01001000
        };

        #5
        data_in = {
            8'b00000000,
            8'b01010101,
            8'b10101000,
            8'b01001000
        };

        #5
        data_in = {
            8'b00100000,
            8'b01010101,
            8'b10101000,
            8'b01001000
        };

        #5
        data_in = {
            8'b10010100,
            8'b11010101,
            8'b10101000,
            8'b11001000
        };
    end
endmodule
