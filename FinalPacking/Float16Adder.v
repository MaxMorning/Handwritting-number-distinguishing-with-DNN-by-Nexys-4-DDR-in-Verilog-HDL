parameter bit = 16;

module Float16Adder(
    input wire signed [(2 * bit - 2):0] iNum1,
    input wire signed [(2 * bit - 2):0] iNum2,
    output reg signed [(2 * bit - 2):0] oNum
    );
    always @ ( * ) begin
        oNum = iNum1 + iNum2;
    end
endmodule
