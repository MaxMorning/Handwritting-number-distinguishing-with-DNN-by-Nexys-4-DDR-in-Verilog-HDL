module Float16Adder(
    input [30:0] iNum1,
    input [30:0] iNum2,
    output reg [30:0] oNum,
    output reg overflow
    );
    
    reg [30:0] numBig;
    reg [30:0] numSmall;
    reg [30:0] result;
    always @ ( * ) begin
        overflow = 0;
        if (iNum1 == 0) begin // iNum1 == 0
            oNum = iNum2;
        end
        else if (iNum2 == 0) begin // iNum2 == 0
            oNum = iNum1;
        end
        else if (iNum1[29:0] == 0 || iNum2[29:0] == 0) begin // iNum1 == 1 or iNum2 == 1
            overflow = 1;
            oNum = 31'b1000000000000000000000000000000;
        end
        else begin
            if (iNum1[30] == iNum2[30]) begin // both positive or negative
                oNum[30] = iNum1[30];

                result = {1'b0, iNum1[29:0]} + {1'b0, iNum2[29:0]};

                if (result[30] == 1) 
                    overflow = 1;
                else
                    oNum[29:0] = result[29:0];
            end
            else begin // different sign
                if (iNum1[29:0] < iNum2[29:0]) begin
                    numBig = iNum2;
                    numSmall = iNum1;
                end
                else begin
                    numBig = iNum1;
                    numSmall = iNum2;
                end
                if (iNum1[29:0] == iNum2[29:0])
                    oNum = {31'h00000000};
                else begin
                    result = numBig[29:0] - numSmall[29:0];
                    oNum[29:0] = result[29:0];
                    
                    if (iNum1[30] == numBig[30]) oNum[30] = 1'b0;
                    else oNum[30] = 1'b1; 
                end
            end
        end
    end
endmodule
