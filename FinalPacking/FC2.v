module full_connect2(
    input ena,
    input clk,
    input iRst_n,
    input [128 * bit - 1:0] data_from_rom,
    input [128 * bit - 1:0] data_from_ram,
    input [(2 * bit - 2):0] data_from_MultAdder,
    
    output reg done,
    output reg [10:0] addr_to_rom,
    output reg [128 * bit - 1:0] opr1_to_MultAdder,
    output reg [128 * bit - 1:0] opr2_to_MultAdder,
    output reg [10 * bit - 1:0] data_to_ram
);

    parameter   rom_addr_base = 11'h401,
                bias_addr_base = 11'h40b;

    reg [3:0] rowCnt;
    reg [128 * bit - 1:0] biases;
    reg [3:0] status;
    reg signed [(2 * bit - 2):0] sum;

    reg signed [(2 * bit - 2):0] adder_opr1;
    reg signed [(2 * bit - 2):0] adder_opr2;

    wire signed [(2 * bit - 2):0] adder_sum;
    Float16Adder adder(
        .iNum1(adder_opr1),
        .iNum2(adder_opr2),

        .oNum(adder_sum)
    );

    always @ (posedge clk) begin
        if (!ena) begin
            done = 0;
            status = 4'b1010;
            addr_to_rom = {11{1'bz}};
            opr1_to_MultAdder = {(128 * bit){1'bz}};
            opr2_to_MultAdder = {(128 * bit){1'bz}};
        end
        else if (!iRst_n) begin
            done = 0;
            rowCnt = 0;
            status = 4'b1010;
            sum = 0;
            // data_to_ram = 0;
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
                        if (data_from_rom == 0)
                            status <= 4'b1011;
                        else begin
                            status = 4'b1000;
                            biases = data_from_rom;
                        end
                    end
                4'b1000: // r = 0
                    begin
                        status = 4'b0000;
                        rowCnt = 0;
                    end
                4'b0000: // ask w,a
                    begin
                        status = 4'b1101;
                        addr_to_rom = rom_addr_base + (9 - rowCnt);
                    end
                4'b1101: // wait for w
                    status = 4'b0001;
                4'b0001: // get w,a ; calc wa
                    begin
                        if (data_from_rom == 0)
                            status <= 4'b0001;
                        else begin
                            status = 4'b0010;
                            opr1_to_MultAdder = data_from_ram;
                            opr2_to_MultAdder = data_from_rom;
                        end
                    end
                4'b0010: // get wa ; calc wa + b
                    begin
                        status = 4'b0011;
                        adder_opr1 = {{5{biases[bit * (rowCnt + 118) + (bit - 1)]}}, biases[bit * (rowCnt + 118) + (bit - 1) -: bit], 10'b0000000000};
                        adder_opr2 = data_from_MultAdder;
                    end
                4'b0011: // get wa + b ; ++r
                    begin
                        status = 4'b0100;
                        data_to_ram[bit * rowCnt + (bit - 1) -: bit] = {adder_sum[(2 * bit - 2)], adder_sum[(2 * bit - 8) -:(bit - 1)]};
                        rowCnt = rowCnt + 1;
                        sum = 0;
                    end
                4'b0100: // r < 10 ?
                    begin
                        if (rowCnt < 10)
                            status = 4'b0000;
                        else
                            status = 4'b0101;
                    end
                4'b0101: // set done
                    begin
                        status = 4'b0101;
                        done = 1;
                    end
                default: 
                    status = 4'b1010;
            endcase
        end
    end
endmodule