module full_connect128(
    input clk,
    input ena,
    input iRst_n,
    input [128 * 8 - 1:0] data_from_memory,
    input [15:0] result_from_MultAdd,
    input wire overflow_from_MultAdd,

    output reg [128 * 8 - 1:0] data1_to_MultAdd,
    output reg [128 * 8 - 1:0] data2_to_MultAdd,
    output reg [11:0] addr_to_memory,
    output reg [10 * 8 - 1:0] result,
    output reg done,
    output reg overflow
);

    parameter addr_base = 12'b010010000000;
    reg [7:0] cnt;
    reg [2:0] status;

    reg [10 * 8 - 1:0] biases;
    reg [15:0] w0a0;
    reg [15:0] w1a1;
    wire [15:0] w0a0PlusW1a1;
    reg [7:0] bias;
    wire overflows;
    wire [7:0] single_result;

    Float8Adder adder(
        .iNum1(w0a0),
        .iNum2(bias),

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
            status = 3'b000; // ask w0
        end
        else begin
            case (status)
                3'b000: // ask w0
                    status <= 3'b001;
                
                3'b001: // get w0, ask a0
                    status <= 3'b010;

                3'b010: // get a0, calc w0 * a0
                    status <= 3'b011;

                3'b011: // get w0 * a0, ask bias
                    status <= 3'b100;

                3'b100: // get bias, calc wa + b
                    status <= 3'b101;
                
                3'b101: // get wa + b, set result, inc cnt
                    status <= 3'b110;
                
                3'b110: // jump or return
                    begin
                        if (cnt < 10) begin
                            status <= 3'b000;
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
                3'b000: // ask w0
                    begin
                        addr_to_memory <= addr_base + 2 * cnt;
                    end
                
                3'b001: // get w0, ask a0
                    begin
                        data1_to_MultAdd <= data_from_memory;
                        addr_to_memory <= addr_base + 2 * cnt + 1;
                    end

                3'b010: // get a0, calc w0 * a0
                    begin
                        data2_to_MultAdd <= data_from_memory;
                    end

                3'b011: // get w0 * a0, ask bias
                    begin
                        w0a0 = result_from_MultAdd;
                        overflow = overflow | overflow_from_MultAdd;
                        if (biases == 0)
                            addr_to_memory <= addr_base + 4 * 128; // biases addr
                    end

                3'b100: // get bias, calc wa + b
                    begin
                        if (biases == 0)
                            biases = data_from_memory;
                        bias <= biases[8 * cnt + 7 -: 8];
                    end
                
                3'b101: // get wa + b, set result, inc cnt
                    begin
                        result[8 * cnt + 7 -: 8] = single_result;
                        overflow = overflow | |overflows;
                        cnt = cnt + 1;
                    end
                default: 
                    begin
                        
                    end
            endcase
    end

endmodule