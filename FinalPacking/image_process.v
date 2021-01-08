module image_process(
    input [32 *32 - 1:0] in_image,

    output [32 * 32 - 1:0] out_image
);

    genvar i;
    generate
        for (i = 0; i < 1024; i = i + 1) begin : PROCESS
            assign out_image[1023 - i] = in_image[i] 
                                        | in_image[(i - 1 + 1024) % 1024] 
                                        | in_image[(i - 32 + 1024) % 1024] 
                                        | in_image[(i - 31 + 1024) % 1024] 
                                        | in_image[(i + 31) % 1024] 
                                        | in_image[(i + 32) % 1024] 
                                        | in_image[(i + 33) % 1024]
                                        | in_image[(i + 34) % 1024] 
                                        | in_image[(i + 64) % 1024]
                                        | in_image[(i + 65) % 1024];
        end
    endgenerate
endmodule