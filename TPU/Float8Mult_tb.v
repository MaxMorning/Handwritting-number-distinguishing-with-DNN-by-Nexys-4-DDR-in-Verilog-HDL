`timescale 1ns / 1ps

module Float8Mult_tb;
    reg [7:0] iNum1;
    reg [7:0] iNum2;
    wire [7:0] oNum;
    wire overflow;
    
    Float8Mult inst(
        .iNum1(iNum1),
        .iNum2(iNum2),
        .oNum(oNum),
        .overflow(overflow)
    );
    
    initial begin
        iNum1 = 8'b00011101; //0.23
        iNum2 = 8'b00101100; //0.44, exp 0 0 0 0 1 0 0 1
    
        #5;
        iNum1 = 8'b00111000; //0.77
        iNum2 = 8'b10111000; //-0.77 exp 1 0 1 1 0 0 1 0
    
        #5;
        iNum1 = 8'b01000011; //1.1875
        iNum2 = 8'b10100011; //-0.296875 exp 1 0 1 0 0 1 1 0
    
        #5;
        iNum1 = 8'b00100000; //0.25
        iNum2 = 8'b10110101; //-0.66 exp 1 0 0 1 0 1 0 1
    
        #5;
        iNum1 = 8'b00000000; // 0
        iNum2 = 8'b10110011; //0.59375 exp 0 0 0 0 0 0 0 0
    
        #5;
        iNum1 = 8'b01111111; // 15.5
        iNum2 = 8'b00111111; // 0.96875 exp 0 1 1 1 1 1 1 0
        
        #5;
        iNum1 = 8'b01111111; // 15.5
        iNum2 = 8'b01010000; // 2 exp overflow
    end
endmodule
