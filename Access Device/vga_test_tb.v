`timescale 1ns / 1ns

module vga_test_tb;
    reg iBusClk, iRstN;
    wire [3:0] oRed;
    wire [3:0] oBlue;
    wire [3:0] oGreen;
    wire oHs, oVs;
    
    vga_test inst(
        .iBusClk(iBusClk),
        .iRstN(iRstN),
        .oRed(oRed),
        .oBlue(oBlue),
        .oGreen(oGreen),
        .oHs(oHs),
        .oVs(oVs)
    );
    
    initial begin
        iBusClk = 0;
        forever
            #5 iBusClk = ~iBusClk;
    end
    
    initial begin
        iRstN = 0;
        #11
        iRstN = 1;
        
        #999
        iRstN = 0;
        
        #2
        iRstN = 1;
    end
endmodule
