module Float8Adder(
    input [14:0] iNum1,
    input [14:0] iNum2,
    output reg [14:0] oNum,
    output reg overflow
    );
    
    reg[14:0] numBig;
    reg[14:0] numSmall;
    reg [14:0] result;
    always @ ( * ) begin
        overflow = 0;
        if (iNum1 == 0) begin // iNum1 == 0
            oNum = iNum2;
        end
        else if (iNum2 == 0) begin // iNum2 == 0
            oNum = iNum1;
        end
        else if (iNum1[13:0] == 0 || iNum2[13:0] == 0) begin // iNum1 == 1 or iNum2 == 1
            overflow = 1;
            oNum = 15'b100000000000000;
        end
        else begin
            if (iNum1[14] == iNum2[14]) begin // both positive or negative
                oNum[14] = iNum1[14];

                result = {1'b0, iNum1[13:0]} + {1'b0, iNum2[13:0]};

                if (result[14] == 1) 
                    overflow = 1;
                else
                    oNum[13:0] = result[13:0];
            end
            else begin // different sign
                if (iNum1[13:0] < iNum2[13:0]) begin
                    numBig = iNum2;
                    numSmall = iNum1;
                end
                else begin
                    numBig = iNum1;
                    numSmall = iNum2;
                end
                if (iNum1[13:0] == iNum2[13:0])
                    oNum = {15'h000};
                else begin
                    result = numBig[13:0] - numSmall[13:0];
                    oNum[13:0] = result[13:0];
                    
                    if (iNum1[14] == numBig[14]) oNum[14] = 1'b0;
                    else oNum[14] = 1'b1; 
                end
            end
        end
    end
endmodule
