`timescale 1ns / 1ps

module TPU_4max_tb;

    reg [10 * 8 - 1:0] data_in;

    wire [7:0] data_max;
    wire [3:0] index;

    max_in_10 inst(
        .data_in(data_in),
        .data_max(data_max),
        .oIndex(index)
    );
    initial begin
        data_in = {
            8'b00000000,
            8'b01010101,
            8'b11101010,
            8'b01001000,
            8'b10101000,
            8'b11101000,
            8'b00101000,
            8'b11101000,
            8'b00101110,
            8'b00101010
        };

        // #5
        // data_in = {
        //     8'b00000000,
        //     8'b01010101,
        //     8'b10101000,
        //     8'b01001000
        // };

        // #5
        // data_in = {
        //     8'b00100000,
        //     8'b01010101,
        //     8'b10101000,
        //     8'b01001000
        // };

        // #5
        // data_in = {
        //     8'b10010100,
        //     8'b11010101,
        //     8'b10101000,
        //     8'b11001000
        // };
    end
endmodule
