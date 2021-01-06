module full_connect1(
    input ena,
    input clk,
    input iRst_n,
    input [128 * bit - 1:0] data_from_rom,
    input [32 * 32 - 1:0] data_from_ram, // 1 bit
    // input [128 * bit - 1:0] data_from_exp,
    input [(2 * bit - 2):0] data_from_MultAdder,
    input overflow_from_MultAdder,
    
    output reg overflow,
    output reg done,
    output reg [10:0] addr_to_rom,
    // output reg [127:0] data_to_exp,
    output reg [128 * bit - 1:0] opr1_to_MultAdder,
    output reg [128 * bit - 1:0] opr2_to_MultAdder,
    output reg [128 * bit - 1:0] data_to_ram
);

    reg [127:0] data_to_exp;
    wire [128 * bit - 1:0] data_from_exp;
    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : GEN
            assign data_from_exp[i * bit + (bit - 1) -: bit] = {2'b00, data_to_exp[i], {(bit - 3){1'b0}}};
        end
    endgenerate
    parameter   rom_addr_base = 11'h000,
                bias_addr_base = 11'h400;

    reg [3:0] colCnt;
    reg [7:0] rowCnt;
    reg [128 * bit - 1:0] biases;
    reg [3:0] status;
    reg [(2 * bit - 2):0] sum;

    reg [(2 * bit - 2):0] adder_opr1;
    reg [(2 * bit - 2):0] adder_opr2;

    wire [(2 * bit - 2):0] adder_sum;
    wire adder_overflow;
    Float16Adder adder(
        .iNum1(adder_opr1),
        .iNum2(adder_opr2),

        .oNum(adder_sum),
        .overflow(adder_overflow)
    );

    always @ (posedge clk) begin
        if (!ena) begin
            overflow = 1'bz;
            done = 0;
            addr_to_rom = {11{1'bz}};
            data_to_exp = {128{1'bz}};
            opr1_to_MultAdder = {(128 * bit){1'bz}};
            opr2_to_MultAdder = {(128 * bit){1'bz}};
        end
        else if (!iRst_n) begin
            overflow = 0;
            done = 0;
            colCnt = 0;
            rowCnt = 0;
            status = 4'b1010;
            sum = 0;
        end
        else begin
            case (status)
                4'b1010: // ask bias
                    begin
                        status = 4'b1100;
                        addr_to_rom = bias_addr_base;
                    end
                4'b1100: // wait for bias
                    status = 4'b1011;
                4'b1011: // get bias
                    begin
                        status = 4'b1000;
                        biases = data_from_rom;
                    end
                4'b1000: // c = 0
                    begin
                        status = 4'b0000;
                        colCnt = 0;
                        sum = 0;
                    end
                4'b0000: // ask w,a
                    begin
                        status = 4'b1101;
                        addr_to_rom = rom_addr_base + 8 * rowCnt + colCnt;
                        data_to_exp = data_from_ram[colCnt * 128 + 127 -: 128];
                    end
                4'b1101: // wait for w
                    status = 4'b0001;
                4'b0001: // get w,a ; calc wa
                    begin
                        status = 4'b0010;
                        opr1_to_MultAdder = data_from_exp;
                        opr2_to_MultAdder = data_from_rom;
                    end
                4'b0010: // get wa ; calc sum += wa
                    begin
                        status = 4'b0011;
                        overflow = overflow | overflow_from_MultAdder;
                        adder_opr1 = sum;
                        adder_opr2 = data_from_MultAdder;
                    end
                4'b0011: // get sum ; ++c
                    begin
                        status = 4'b0100;
                        overflow = overflow | adder_overflow;
                        sum = adder_sum;
                        colCnt = colCnt + 1;
                    end
                4'b0100: // c < 8 ?
                    begin
                        if (colCnt < 8)
                            status = 4'b0000;
                        else
                            status = 4'b0101;
                    end
                4'b0101: // calc sum += bias
                    begin
                        status = 4'b0110;
                        adder_opr1 = sum;
                        adder_opr2 = {biases[bit * rowCnt + (bit - 1)], 2'b00, biases[bit * rowCnt + (bit - 2) -: (bit - 1)], {(bit - 3){1'b0}}};
                    end
                4'b0110 : // get sum += bias
                    begin
                        status = 4'b0111;
                        overflow = overflow | adder_overflow;
                        data_to_ram[bit * rowCnt + (bit - 1) -: bit] = (adder_sum[(2 * bit - 2)] == 0 || adder_sum[(2 * bit - 3):0] == 0) ? {adder_sum[(2 * bit - 2)], adder_sum[(2 * bit - 5):(bit - 3)]} : {bit{1'b0}}; // relu
                        rowCnt = rowCnt + 1;
                    end
                4'b0111 : // r < 128 ?
                    begin
                        if (rowCnt < 128)
                            status = 4'b1000;
                        else
                            status = 4'b1001;
                    end
                4'b1001: // set done
                    begin
                        status = 4'b1001;
                        done = 1;
                    end
                default: 
                    status = 4'b1010;
            endcase
        end
    end
endmodule