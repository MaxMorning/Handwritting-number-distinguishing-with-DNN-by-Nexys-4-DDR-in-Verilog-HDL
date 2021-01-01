`timescale 1ns / 1ps

module TPU_Conv_25_tb;

    reg [25 * 8 - 1:0] data_in1;
    reg [25 * 8 - 1:0] data_in2;

    wire [7:0] data_out;
    wire overflow;
    
    TPU_Conv_25 inst(
        .data_in1(data_in1),
        .data_in2(data_in2),
        .data_out(data_out),
        .overflow(overflow)
    );
    
    initial begin
        data_in1 = {25{8'b00001000}}; // 0.0625
        data_in2 = {25{8'b00100000}}; // 0.25
        // exp 0.390625 8'b00110010  8'h32
        
        #5;
        data_in1 = {25{8'b00101100}}; 
        data_in2 = {25{8'b00100100}}; // 0.28125
        
        #5;
        data_in1 = {25{8'b00001100}}; // 0.0625 + 0.03125 = 0.09375
        data_in2 = {25{8'b00100100}}; // 0.25 + 0.03125 = 0.28125
        // exp 8'b0101 0100  8'h54
        
        #5;
        data_in1 = {25{8'b00011100}}; // 0.125 + 0.0625 + 0.03125 = 0.21875
        data_in2 = {25{8'b00001100}}; // 0.0625 + 0.3125 = 0.09375
        // exp 8'b0100 0001  8'h41
    end
endmodule
