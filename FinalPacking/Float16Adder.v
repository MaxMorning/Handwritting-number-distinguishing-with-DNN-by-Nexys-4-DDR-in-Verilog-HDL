module Float16Adder(
    input [(2 * bit - 2):0] iNum1,
    input [(2 * bit - 2):0] iNum2,
    output reg [(2 * bit - 2):0] oNum,
    output reg overflow
    );
    
    reg [(2 * bit - 2):0] numBig;
    reg [(2 * bit - 2):0] numSmall;
    reg [(2 * bit - 2):0] result;
    always @ ( * ) begin
        overflow = 0;
        if (iNum1 == 0) begin // iNum1 == 0
            oNum = iNum2;
        end
        else if (iNum2 == 0) begin // iNum2 == 0
            oNum = iNum1;
        end
        else if (iNum1[(2 * bit - 3):0] == 0 || iNum2[(2 * bit - 3):0] == 0) begin // iNum1 == 1 or iNum2 == 1
            overflow = 1;
            oNum = {1'b1, {(2 * bit - 2){1'b0}}};
        end
        else begin
            if (iNum1[(2 * bit - 2)] == iNum2[(2 * bit - 2)]) begin // both positive or negative
                oNum[(2 * bit - 2)] = iNum1[(2 * bit - 2)];

                result = {1'b0, iNum1[(2 * bit - 3):0]} + {1'b0, iNum2[(2 * bit - 3):0]};

                if (result[(2 * bit - 2)] == 1) 
                    overflow = 1;
                else
                    oNum[(2 * bit - 3):0] = result[(2 * bit - 3):0];
            end
            else begin // different sign
                if (iNum1[(2 * bit - 3):0] < iNum2[(2 * bit - 3):0]) begin
                    numBig = iNum2;
                    numSmall = iNum1;
                end
                else begin
                    numBig = iNum1;
                    numSmall = iNum2;
                end
                if (iNum1[(2 * bit - 3):0] == iNum2[(2 * bit - 3):0])
                    oNum = 0;
                else begin
                    result = numBig[(2 * bit - 3):0] - numSmall[(2 * bit - 3):0];
                    oNum[(2 * bit - 3):0] = result[(2 * bit - 3):0];
                    
                    if (iNum1[(2 * bit - 2)] == numBig[(2 * bit - 2)]) oNum[(2 * bit - 2)] = 1'b0;
                    else oNum[(2 * bit - 2)] = 1'b1; 
                end
            end
        end
    end
endmodule
