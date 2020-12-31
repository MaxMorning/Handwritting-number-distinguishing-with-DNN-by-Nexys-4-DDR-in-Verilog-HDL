module Float8Adder(
    input [7:0] iNum1,
    input [7:0] iNum2,
    output reg [7:0] oNum,
    output reg overflow
    );
    
    reg[5:0] temp1 = 0;
    reg[5:0] temp2 = 0;
    reg[5:0] temp3 = 0;
    reg[7:0] numBig;
    reg[7:0] numSmall;
    always @ ( * ) begin
        overflow = 0;
        if (|iNum1[6:0] == 0) begin // iNum1 == 0
            oNum = iNum2;
        end
        else if (|iNum2[6:0] == 0) begin // iNum2 == 0
            oNum = iNum1;
        end
        else begin
            if (iNum1[6:3] < iNum2[6:3]) begin
                numBig = iNum2;
                numSmall = iNum1;
            end
            else if (iNum1[6:3] > iNum2[6:3]) begin
                numBig = iNum1;
                numSmall = iNum2;
            end
            else if (iNum1[2:0] < iNum2[2:0]) begin
                numBig = iNum2;
                numSmall = iNum1;
            end
            else begin
                numBig = iNum1;
                numSmall = iNum2;
            end
            
            if (iNum1[7] == iNum2[7]) begin // both positive or negative
                oNum[7] = iNum1[7];

                
                temp1 = {1'b1, numBig[2:0]};
                temp2 = {1'b1, numSmall[2:0]} >> (numBig[6:3] - numSmall[6:3]);
                temp3 = temp1 + temp2;
                if (temp3[4] == 1) begin //carry
                    if (numBig[6:3] != 4'b1111) begin
                        oNum[6:3] = numBig[6:3] + 1;
                        oNum[2:0] = temp3[3:1];
                    end
                    else overflow = 1;
                end
                else begin
                    oNum[6:3] = numBig[6:3];
                    oNum[2:0] = temp3[2:0];
                end
            end
            else begin // different sign
                if (iNum1[6:0] == iNum2[6:0]) oNum = {8'h00};
                else begin
                    temp1 = {1'b1, numBig[2:0]};
                    temp2 = {1'b1, numSmall[2:0]} >> (numBig[6:3] - numSmall[6:3]);
                    temp3 = temp1 - temp2;
                    if (temp3[3] == 1) oNum[6:0] = {numBig[6:3], temp3[2:0]};
                    else if (temp3[2] == 1) oNum[6:0] = {numBig[6:3] - 1, temp3[1:0], 1'b0};
                    else if (temp3[1] == 1) oNum[6:0] = {numBig[6:3] - 2, temp3[0], 2'b00};
                    else oNum[6:0] = {numBig[6:3] - 3, 3'b000};
                    
                    if (iNum1[7] == numBig[7]) oNum[7] = 1'b0;
                    else oNum[7] = 1'b1; 
                end
            end
        end
    end
endmodule
