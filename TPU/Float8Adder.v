module Float8Adder(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [7:0] oNum,
    output reg overflow
    );
    
    reg[7:0] numBig;
    reg[7:0] numSmall;
    reg [7:0] result;
    always @ ( * ) begin
        overflow = 0;
        if (|iNum1[7:0] == 0) begin // iNum1 == 0
            oNum = iNum2;
        end
        else if (|iNum2[7:0] == 0) begin // iNum2 == 0
            oNum = iNum1;
        end
        else if (|iNum1[6:0] == 0 || |iNum2[7:0] == 0) begin // iNum1 == 1 or iNum2 == 1
            overflow = 1;
            oNum = 8'b10000000;
        end
        else begin
            if (iNum1[7] == iNum2[7]) begin // both positive or negative
                oNum[7] = iNum1[7];

                result = {1'b0, iNum1[6:0]} + {1'b0, iNum2[6:0]};

                if (result[7] == 1) 
                    overflow = 1;
                else
                    oNum[6:0] = result[6:0];
            end
            else begin // different sign
                if (iNum1[6:0] < iNum2[6:0]) begin
                    numBig = iNum2;
                    numSmall = iNum1;
                end
                else begin
                    numBig = iNum1;
                    numSmall = iNum2;
                end
                if (iNum1[6:0] == iNum2[6:0])
                    oNum = {8'h00};
                else begin
                    oNum[6:0] = numBig[6:0] - numSmall[6:0];
                    
                    if (iNum1[7] == numBig[7]) oNum[7] = 1'b0;
                    else oNum[7] = 1'b1; 
                end
            end
        end
    end
endmodule
