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

module multadd_tb;
    reg [128 * 16 - 1:0] data_in1;
    reg [128 * 16 - 1:0] data_in2;

    wire [(2 * 16 - 2):0] data_out;
    wire overflow;
    
    TPU_MultAdd inst(
        .data_in1(data_in1),
        .data_in2(data_in2),
        .data_out(data_out),
        .overflow(overflow)
    );
    
    initial begin
        data_in1 = {128{16'b0000010000000000}};
        data_in2 = {128{16'b0000001000000000}};
    end
endmodule