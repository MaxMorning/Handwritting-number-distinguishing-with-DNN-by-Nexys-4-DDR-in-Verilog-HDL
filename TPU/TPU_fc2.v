module full_connect128(
    input clk,
    input ena,
    input iRst_n,
    input [128 * 8 - 1:0] data_from_memory,
    input [14:0] result_from_MultAdd,
    input wire overflow_from_MultAdd,

    output reg [128 * 8 - 1:0] data1_to_MultAdd,
    output reg [128 * 8 - 1:0] data2_to_MultAdd,
    output reg [11:0] addr_to_memory,
    output reg [10 * 8 - 1:0] result,
    output reg done,
    output reg overflow
);

    parameter addr_base = 12'b010010000000;
    parameter a_addr_base = 12'b011001000000;
    parameter b_addr_base = 12'b011011000000;
    reg [7:0] cnt;
    reg [2:0] status;

    reg [128 * 8 - 1:0] a;
    reg [10 * 8 - 1:0] biases;
    reg [14:0] wa;
    reg [7:0] bias;
    wire overflows;
    wire [14:0] single_result;

    Float8Adder adder(
        .iNum1(wa),
        .iNum2({bias, 8'h00}),

        .oNum(single_result),
        .overflow(overflows)
    );

    always @ (posedge clk) begin
        if (!ena) begin
            data1_to_MultAdd <= {(128 * 8){1'bz}};
            data2_to_MultAdd <= {(128 * 8){1'bz}};
            addr_to_memory <= {12{1'bz}};
            result <= {(10 * 8){1'bz}};
            done <= 1'bz;
            overflow <= 1'bz;
        end
        else if (!iRst_n) begin
            cnt = 0;
            biases = 0;
            overflow = 0;
            done = 1;
            status = 3'b000; // ask a
        end
        else begin
            case (status)
                3'b000: // ask a
                    status <= 3'b001;
                
                3'b001: // get a, ask bias
                    status <= 3'b010;

                3'b010: // get bias
                    status <= 3'b011;

                3'b011: // ask w
                    status <= 3'b100;

                3'b100: // get w, calc wa
                    status <= 3'b101;
                
                3'b101: // get wa, calc wa + b
                    status <= 3'b110;
                
                3'b110: // get wa + b, set result. inc cnt
                    status <= 3'b111;

                3'b111: // jump or return
                    begin
                        if (cnt < 10) begin
                            status <= 3'b011;
                        end
                        else begin
                            done <= 1;
                        end
                    end
                default: 
                    status <= 3'b000;
            endcase
        end
    end

    always @ (status) begin
        case (status)
                3'b000: // ask a
                    begin
                        addr_to_memory <= a_addr_base;
                    end
                
                3'b001: // get a, ask bias
                    begin
                        a <= data_from_memory;
                        addr_to_memory <= b_addr_base;
                    end

                3'b010: // get bias
                    begin
                        biases <= data_from_memory[128 * 8 - 1 -: 10 * 8];
                    end

                3'b011: // ask w
                    begin
                        addr_to_memory <= addr_base + cnt;
                    end

                3'b100: // get w, calc wa
                    begin
                        data1_to_MultAdd <= data_from_memory;
                        data2_to_MultAdd <= a;
                    end
                
                3'b101: // get wa, calc wa + b
                    begin
                        wa <= result_from_MultAdd;
                        overflow = overflow | overflow_from_MultAdd;
                    end

                3'b110: // get wa + b, set result. inc cnt
                    begin
                        result[8 * cnt + 7 -: 8] = single_result[14:7];
                        overflow = overflow | overflows;
                        cnt = cnt + 1;
                    end
                default: 
                    begin
                        
                    end
            endcase
    end

endmodule