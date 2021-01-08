module display7(
    input ena,
    input [3:0] iData,
    output [6:0] oData
    );
    
    assign oData[6] = ena ? (~iData[3] & ~iData[2] & ~iData[1]) | (iData[2] & iData[1] & iData[0]) : 1'b1;
    assign oData[5] = ena ? (~iData[3] & ~iData[2] & iData[0]) | (~iData[2] & iData[1]) | (iData[1] & iData[0]) : 1'b0;
    assign oData[4] = ena ? iData[0] | (iData[2] & ~iData[1]) : 1'b0;
    assign oData[3] = ena ? (~iData[3] & ~iData[2] & ~iData[1] & iData[0]) | (iData[2] & ~iData[1] & ~iData[0]) | (iData[2] & iData[1] & iData[0]) : 1'b0;
    assign oData[2] = ena ? ~iData[2] & iData[1] & ~iData[0] : 1'b1;
    assign oData[1] = ena ? (iData[2] & ~iData[1] & iData[0]) | (iData[2] & iData[1] & ~iData[0]) : 1'b1;
    assign oData[0] = ena ? (~iData[3] & ~iData[2] & ~iData[1] & iData[0]) | (iData[2] & ~iData[1] & ~iData[0]) : 1'b0;
endmodule
