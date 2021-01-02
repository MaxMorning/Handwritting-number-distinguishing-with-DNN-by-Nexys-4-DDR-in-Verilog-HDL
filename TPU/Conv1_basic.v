// process at posedge clk, return data at negedge clk;
module conv1(
    input clk,
    input ena,
    input iRst_n,
    input [32 * 32 * 8 - 1:0] tensor_in,
    input [25 * 8 - 1:0] filter_in,
    input [7:0] bias_in,

    output reg [28 * 28 * 8 - 1:0] tensor_out,
    output reg overflow,
    output reg done
);

    reg [4:0] rowCnt;
    reg [4:0] colCnt;

    reg [5 * 5 * 8 - 1:0] opr1;
    reg [5 * 5 * 8 - 1:0] opr2;
    wire [7:0] conv_out;
    wire [14:0] result_out;
    // reg conv_overflow;
    wire wire_conv_overflow;
    // reg bias_overflow;
    wire wire_bias_overflow;

    TPU_Conv_25 conv(
        .data_in1(opr1),
        .data_in2(opr2),

        .data_out(conv_out),
        .overflow(wire_conv_overflow)
    );

    Float8Adder adder(
        .iNum1({conv_out, 7'h00}),
        .iNum2({bias_in, 7'h00}),

        .oNum(result_out),
        .overflow(wire_bias_overflow)
    );
    always @ (posedge clk) begin
        if (ena) begin
            if (!iRst_n) begin
                rowCnt <= 23;
                colCnt <= 23;
                done <= 0;
                overflow <= 0;
            end
            else begin
                opr1 <= {tensor_in[((rowCnt + 4) * 32 + (colCnt + 4)) * 8 + 7 -: 5 * 8],
                        tensor_in[((rowCnt + 3) * 32 + (colCnt + 4)) * 8 + 7 -: 5 * 8],
                        tensor_in[((rowCnt + 2) * 32 + (colCnt + 4)) * 8 + 7 -: 5 * 8],
                        tensor_in[((rowCnt + 1) * 32 + (colCnt + 4)) * 8 + 7 -: 5 * 8],
                        tensor_in[((rowCnt + 0) * 32 + (colCnt + 4)) * 8 + 7 -: 5 * 8]};

                opr2 <= filter_in;
            end
        end
        else begin
            tensor_out <= {(28 * 28 * 8){1'bz}};
            overflow <= 1'bz;
            done <= 1'bz;
        end
    end

    always @ (negedge clk) begin
        if (ena && iRst_n) begin
            tensor_out[(rowCnt * 28 + colCnt) * 8 + 7 -: 8] <= result_out[14:7];
            overflow <= overflow | wire_conv_overflow | wire_bias_overflow;

            if (colCnt == 5'd00) begin
                colCnt <= 27;
                if (rowCnt == 5'd00) begin
                    rowCnt <= 27;
                    done <= 1;
                end
                else
                    rowCnt <= rowCnt - 1;
            end
            else
                colCnt <= colCnt - 1;
            
        end
    end
endmodule