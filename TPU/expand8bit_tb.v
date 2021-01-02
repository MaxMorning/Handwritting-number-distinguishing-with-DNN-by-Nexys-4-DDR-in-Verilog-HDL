`timescale 1ns / 1ps

module expand8bit_tb;

    reg [32 * 32 - 1:0] data_in;
    reg [2:0] addr;
    wire [128 * 8 - 1:0] data_out;

    expand_to_8bit inst(
        .data_in(data_in),
        .addr(addr),
        .data_out(data_out)
    );
    initial begin
        data_in = {64{8'b00110011, 8'b10101010}};
        addr = 0;

        #5
        addr = 4;

        #5
        addr = 5;

        #5
        addr = 7;
    end
endmodule
