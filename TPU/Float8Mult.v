module Float8Mult(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [7:0] oNum,
    );
    
    reg [13:0] result;
    always @ ( * ) begin
        if (|iNum1[7:0] == 0 || |iNum2[7:0] == 0)
            oNum = 8'h00;
        else if (| iNum1[6:0] == 0)
            oNum = iNum2;
        else if (| iNum2[6:0] == 0)
            oNum = iNum1;
        else begin
            result = iNum1[6:0] * iNum2[6:0];
            oNum[7] = iNum1[7] ^ iNum2[7];
            oNum[6:0] = result[13:7];
        end
    end
endmodule
