`timescale 1ns / 1ps

module Conv1_tb;
    reg clk;
    reg ena;
    reg iRst_n;
    reg [28 * 28 * 8 - 1:0] tensor_in;
    reg [25 * 8 - 1:0] filter_in;
    reg [7:0] bias_in;

    wire [24 * 24 * 8 - 1:0] tensor_out;
    wire overflow;
    wire done;

    conv1 inst(
        .clk(clk),
        .ena(ena),
        .iRst_n(iRst_n),
        .tensor_in(tensor_in),
        .filter_in(filter_in),
        .bias_in(bias_in),
        .tensor_out(tensor_out),
        .overflow(overflow),
        .done(done)
    );

    initial begin
        clk = 0;
        forever
            #5 clk = ~clk;
    end
        
    initial begin
        iRst_n = 0;
        ena = 1;

        #14
        iRst_n = 1;
//        tensor_in = {(28 * 28){8'b00100010}}; // 1 / 4 + 1 / 64 = 0.265625
//        filter_in = {(5 * 5){8'b00000111}}; // 7 / 128 = 0.0546875
//        bias_in = 8'b00001011; // 11 / 128 = 0.859375
//        // exp : 0.449 8'b0011 1001
        tensor_in = {(28 * 28){8'b0100010}}; // 1 / 2 + 1 / 64 = 0.515625
        filter_in = {(5 * 5){8'b01000111}}; // 1/ 2 + 7 / 128 = 0.5546875
        bias_in = 8'b00001011; // 11 / 128 = 0.859375
        // exp : overflow
    end

endmodule
