module conv1(
    input clk,
    input ena,
    input prev_done,
    input [32 * 8 - 1:0] tensor_in,
    input [25 * 8 - 1:0] filter_in,

    output reg done,
    output [32 * 8 - 1:0] tensor_out,
);
    reg [31 * 8 - 1:0] tempOpr;
    reg [4:0] rowCnt; // 0 ~ 31
    reg [2:0] colCnt; // 0 ~ 4

    always @ (posedge clk) begin
        
    end
endmodule