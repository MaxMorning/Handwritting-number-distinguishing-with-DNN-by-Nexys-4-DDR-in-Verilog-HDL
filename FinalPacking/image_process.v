module image_process(
    input [32 *32 - 1:0] in_image,

    output [32 * 32 - 1:0] out_image
);

    genvar i;
    generate
        for (i = 0; i < 1024; i = i + 1) begin : PROCESS
            assign out_image[1023 - i] = in_image[i] | in_image[(i + 1024 - 1) % 1024] & in_image[(i + 1024 - 32) % 1024] | in_image[(i + 1024 - 32) % 1024] & in_image[(i + 1024 - 33) % 1024] | in_image[(i + 1024 - 1) % 1024] & in_image[(i + 1024 - 33) % 1024];
        end
    endgenerate
endmodule