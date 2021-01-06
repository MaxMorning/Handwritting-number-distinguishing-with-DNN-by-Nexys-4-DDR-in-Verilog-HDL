module Float16Mult(
    input [(bit - 1):0] iNum1,
    input [(bit - 1):0] iNum2,
    output reg [(2 * bit - 2):0] oNum
    );
    
    reg [(2 * bit - 2):0] result;
    always @ ( * ) begin
        if (|iNum1[(bit - 1):0] == 0 || |iNum2[(bit - 1):0] == 0)
            oNum = 0;
        else if (| iNum1[(bit - 2):0] == 0)
            oNum = {iNum2, {(bit - 1){1'b0}}};
        else if (| iNum2[(bit - 2):0] == 0)
            oNum = {iNum1, {(bit - 1){1'b0}}};
        else begin
            result = iNum1[(bit - 2):0] * iNum2[(bit - 2):0];
            oNum[(2 * bit - 2)] = iNum1[(bit - 1)] ^ iNum2[(bit - 1)];
            oNum[(2 * bit - 3):0] = result;
        end
    end
endmodule
