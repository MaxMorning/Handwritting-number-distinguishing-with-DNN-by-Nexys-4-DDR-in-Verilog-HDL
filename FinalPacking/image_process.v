module image_process(
    input [32 *32 - 1:0] in_image,

    output [32 * 32 - 1:0] show_image,
    output [32 * 32 - 1:0] out_image
);

    genvar i;
    generate
        for (i = 0; i < 1024; i = i + 1) begin : PROCESS
            if (i == 0) // left top corner
                assign out_image[1023 - 0] = in_image[0] | in_image[1] | in_image[32];
            else if (i == 31) // right top corner
                assign out_image[1023 - 31] = in_image[31] | in_image[30] | in_image[63];
            else if (i == 1023) // right down corner
                assign out_image[1023 - 1023] = in_image[1023] | in_image[1022] | in_image[991];
            else if (i == 992) // left down corner
                assign out_image[1023 - 992] = in_image[992] | in_image[993] | in_image[960];
            else if (i < 31) // top side
                assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i + 1] | in_image[i + 32];
            else if (i > 992) // down side
                assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i + 1] | in_image[i - 32];
            else if (i % 32 == 0) // left side
                assign out_image[1023 - i] = in_image[i] | in_image[i + 1] | in_image[i - 32] | in_image[i + 32];
            else if (i % 32 == 31) // right side
                assign out_image[1023 - i] = in_image[i] | in_image[i - 1] | in_image[i - 32] | in_image[i + 32];
            else // others
                assign out_image[1023 - i] = in_image[i] 
                                            | in_image[(i - 1 + 1024) % 1024] 
                                            | in_image[(i - 32 + 1024) % 1024] 
                                            | in_image[(i + 1) % 1024] 
                                            | in_image[(i + 32) % 1024];
        end
        for (i = 0; i < 1024; i = i + 1) begin : PROCESS2
            assign show_image[i] = out_image[1023 - i];
        end
    endgenerate
endmodule