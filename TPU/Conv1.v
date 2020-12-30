module conv1(
    input clk,
    input ena,
    input [28 * 28 * 8 - 1:0] tensor_in,

    output reg done,
    output [24 *24 * 32 - 1:0] tensor_out,
);

endmodule