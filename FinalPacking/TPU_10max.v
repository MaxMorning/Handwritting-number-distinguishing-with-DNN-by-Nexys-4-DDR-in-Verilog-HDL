module max_in_10(
    input wire [10 * bit - 1:0] data_in,

    output reg signed [(bit - 1):0] data_max,
    output [3:0] oIndex
);

    reg [3:0] cnt;
    reg [3:0] index;
    reg signed [bit - 1:0] cmp_num1;
    assign oIndex = 9 - index;
    always @ (*) begin
        data_max = data_in[(bit - 1):0];
        index = 0;

        for (cnt = 1; cnt < 10; cnt = cnt + 1) begin
            cmp_num1 = data_in[bit * cnt + bit - 1 -: bit];
            if (data_max < cmp_num1) begin
                data_max = cmp_num1;
                index = cnt;
            end
        end
    end
endmodule