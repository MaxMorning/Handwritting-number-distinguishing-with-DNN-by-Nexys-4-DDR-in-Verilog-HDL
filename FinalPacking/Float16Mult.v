module Float16Mult(
    input [15:0] iNum1,
    input [15:0] iNum2,
    output reg [30:0] oNum
    );
    
    reg [30:0] result;
    always @ ( * ) begin
        if (|iNum1[15:0] == 0 || |iNum2[15:0] == 0)
            oNum = 31'h00000000;
        else if (| iNum1[14:0] == 0)
            oNum = {iNum2, 16'h0000};
        else if (| iNum2[14:0] == 0)
            oNum = {iNum1, 16'h0000};
        else begin
            result = iNum1[14:0] * iNum2[14:0];
            oNum[30] = iNum1[15] ^ iNum2[15];
            oNum[29:0] = result;
        end
    end
endmodule
