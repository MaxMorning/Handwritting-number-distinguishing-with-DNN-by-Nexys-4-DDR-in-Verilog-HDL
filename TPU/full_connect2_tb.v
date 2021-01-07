//`timescale 1ns / 1ps

//module full_connect2_tb;

//    reg ena;
//    reg clk;
//    reg iRst_n;
//    reg [128 * 8 - 1:0] data_from_rom;
//    reg [128 * 8 - 1:0] data_from_ram;
//    reg [14:0] data_from_MultAdder;
//    reg overflow_from_MultAdder;
    
//    wire overflow;
//    wire done;
//    wire [31:0] addr_to_rom;
//    // wire [31:0] addr_to_ram;
//    wire [128 * 8 - 1:0] opr1_to_MultAdder;
//    wire [128 * 8 - 1:0] opr2_to_MultAdder;
//    wire [10 * 8 - 1:0] data_to_ram;

//    full_connect2 inst(
//        .ena(ena),
//        .clk(clk),
//        .iRst_n(iRst_n),
//        .data_from_rom(data_from_rom),
//        .data_from_ram(data_from_ram),
//        .data_from_MultAdder(data_from_MultAdder),
//        .overflow_from_MultAdder(overflow_from_MultAdder),

//        .overflow(overflow),
//        .done(done),
//        .addr_to_rom(addr_to_rom),
//        // .addr_to_ram(addr_to_ram),
//        .opr1_to_MultAdder(opr1_to_MultAdder),
//        .opr2_to_MultAdder(opr2_to_MultAdder),
//        .data_to_ram(data_to_ram)
//    );

//    initial begin
//        clk = 0;
//        forever
//            #5 clk = ~clk;
//    end

//    initial begin
//        ena = 1;
//        iRst_n = 0;

//        #14
//        iRst_n = 1;
//        data_from_rom = {128{8'b00000001}};
//        data_from_ram = {128{8'b00000010}};
//        data_from_MultAdder = 15'b000000101000011;
//        overflow_from_MultAdder = 0;
        
//        #10000
//        ena = 0;
//    end
//endmodule
`timescale 1ns / 1ps

module mult_tb;
    reg [16 - 1:0] data_in1;
    reg [16 - 1:0] data_in2;

    wire [(2 * 16 - 2):0] data_out;
    
    Float16Mult inst(
        .iNum1(data_in1),
        .iNum2(data_in2),
        .oNum(data_out)
    );
    
    initial begin
        data_in1 = 16'b0001010101001100;
        data_in2 = 16'b0001011101001100;
    end
endmodule