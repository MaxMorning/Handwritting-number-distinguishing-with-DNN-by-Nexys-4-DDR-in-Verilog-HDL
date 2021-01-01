module Float8Mult(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [14:0] oNum
    );
    
    reg [13:0] result;
    always @ ( * ) begin
        if (|iNum1[7:0] == 0 || |iNum2[7:0] == 0)
            oNum = 14'h000;
        else if (| iNum1[6:0] == 0)
            oNum = {iNum2, 8'h00};
        else if (| iNum2[6:0] == 0)
            oNum = {iNum1, 8'h00};
        else begin
            result = iNum1[6:0] * iNum2[6:0];
            oNum[14] = iNum1[7] ^ iNum2[7];
            oNum[13:0] = result;
        end
    end
endmodule
