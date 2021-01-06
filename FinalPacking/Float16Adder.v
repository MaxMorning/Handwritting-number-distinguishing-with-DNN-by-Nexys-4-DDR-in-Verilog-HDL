parameter bit = 16;

module Float16Adder(
    input [(2 * bit - 2):0] iNum1,
    input [(2 * bit - 2):0] iNum2,
    output reg [(2 * bit - 2):0] oNum,
    output reg overflow
    );
    
    reg [(2 * bit - 2):0] result;
    always @ ( * ) begin
        overflow = 0;
        if (iNum1 == {1'b1, {(2 * bit - 2){1'b0}}} || iNum2 == {1'b1, {(2 * bit - 2){1'b0}}}) begin // iNum1 == 4 or iNum2 == 4
            overflow = 1;
            oNum = {1'b1, {(2 * bit - 2){1'b0}}};
        end
        else begin
            if (iNum1[(2 * bit - 2)] == iNum2[(2 * bit - 2)]) begin // both positive or negative
                oNum[(2 * bit - 2)] = iNum1[(2 * bit - 2)];

                result = {1'b0, iNum1[(2 * bit - 3):0]} + {1'b0, iNum2[(2 * bit - 3):0]};

                if (result[(2 * bit - 2)] == 1) begin
                    overflow = 1;
                    // oNum = {1'b1, {(2 * bit - 3){1'b0}}, ~oNum[(2 * bit - 2)]};
                end
                else
                    oNum[(2 * bit - 3):0] = result[(2 * bit - 3):0];
            end
            else begin // different sign
                if (iNum1[(2 * bit - 3):0] < iNum2[(2 * bit - 3):0]) begin
                    result = iNum2[(2 * bit - 3):0] - iNum1[(2 * bit - 3):0];
                    oNum[(2 * bit - 2)] = iNum2[(2 * bit - 2)];
                end
                else begin
                    result = iNum1[(2 * bit - 3):0] - iNum2[(2 * bit - 3):0];
                    oNum[(2 * bit - 2)] = iNum1[(2 * bit - 2)];
                end
                oNum[(2 * bit - 3):0] = result[(2 * bit - 3):0];
            end
        end
    end
endmodule
