module image_process(
    input [32 *32 - 1:0] in_image,

    output [32 * 32 - 1:0] show_image,
    output [32 * 32 - 1:0] out_image
);

    assign out_image[1023 - 0] = in_image[0] | in_image[1] | in_image[32]; // left top corner
    assign out_image[1023 - 31] = in_image[31] | in_image[30] | in_image[63]; // right top corner
    assign out_image[1023 - 1023] = in_image[1023] | in_image[1022] | in_image[991]; // right down corner
    assign out_image[1023 - 992] = in_image[992] | in_image[993] | in_image[960]; // left down corner

    genvar i;

    generate
        for (i = 1; i < 31; i = i + 1) begin : TS // top side
            assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i + 1] | in_image[i + 32];
        end
    endgenerate

    generate
        for (i = 993; i < 1023; i = i + 1) begin : DS // down side
            assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i + 1] | in_image[i - 32];
        end
    endgenerate

    generate
        for (i = 32; i < 992; i = i + 32) begin : LS // left side
            assign out_image[1023 - i] = in_image[i] | in_image[i + 1] | in_image[i - 32] | in_image[i + 32];
        end
    endgenerate

    generate
        for (i = 63; i < 1023; i = i + 32) begin : RS // right side
            assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i - 32] | in_image[i + 32];
        end
    endgenerate

    genvar r, c;
    generate
        for (r = 1; r <= 30; r = r + 1) begin : R
            for (c = 1; c <= 30; c = c + 1) begin : C
                assign out_image[1023 - (32 * r + c)] = in_image[32 * r + c] 
                                                        | in_image[32 * r + c + 1] 
                                                        | in_image[32 * r + c - 1] 
                                                        | in_image[32 * (r + 1) + c] 
                                                        | in_image[32 * (r - 1) + c];
            end
        end
    endgenerate
    
    generate
        for (i = 0; i < 1024; i = i + 1) begin : PROCESS2
            assign show_image[i] = out_image[1023 - i];
        end
    endgenerate
endmodule