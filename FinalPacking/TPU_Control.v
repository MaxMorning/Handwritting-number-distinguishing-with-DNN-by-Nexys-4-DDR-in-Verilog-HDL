module TPU_Control(
    input clk,
    input ena,
    input iRst_n,
    input [32 * 32 * 1 - 1:0] input_image,

    output reg [3:0] num_out,
    output reg done
);

    reg [3:0] status;
    reg FC1_ena, FC2_ena, FC3_ena;
    reg FC1_rstn, FC2_rstn, FC3_rstn; 
    wire FC1_done, FC2_done, FC3_done;

    wire [10:0] addr_control_rom;
    wire [10:0] addr_fc1_rom;
    wire [10:0] addr_fc2_rom;
    wire [10:0] addr_fc3_rom;


    assign addr_control_rom = FC1_ena ? addr_fc1_rom : FC2_ena ? addr_fc2_rom : FC3_ena ? addr_fc3_rom : {11{1'bz}};

    wire [(128 * bit - 1):0] data_rom_control;
    wire [(128 * bit - 1):0] data_rom_fc1;
    wire [(128 * bit - 1):0] data_rom_fc2;
    wire [(128 * bit - 1):0] data_rom_fc3;

    assign data_rom_fc1 = FC1_ena ? data_rom_control : {(128 * bit){1'bz}};
    assign data_rom_fc2 = FC2_ena ? data_rom_control : {(128 * bit){1'bz}};
    assign data_rom_fc3 = FC3_ena ? data_rom_control : {(128 * bit){1'bz}};
    
    wire [(2 * bit - 2):0] data_MultAdder_control;
    wire [(2 * bit - 2):0] data_MultAdder_fc1;
    wire [(2 * bit - 2):0] data_MultAdder_fc2;
    wire [(2 * bit - 2):0] data_MultAdder_fc3;

    assign data_MultAdder_fc1 = FC1_ena ? data_MultAdder_control : {(2 * bit - 1){1'bz}};
    assign data_MultAdder_fc2 = FC2_ena ? data_MultAdder_control : {(2 * bit - 1){1'bz}};
    assign data_MultAdder_fc3 = FC3_ena ? data_MultAdder_control : {(2 * bit - 1){1'bz}};

    wire [128 * bit - 1:0] opr1_control_MultAdder;
    wire [128 * bit - 1:0] opr1_fc1_MultAdder;
    wire [128 * bit - 1:0] opr1_fc2_MultAdder;
    wire [128 * bit - 1:0] opr1_fc3_MultAdder;

    assign opr1_control_MultAdder = FC1_ena ? opr1_fc1_MultAdder : FC2_ena ? opr1_fc2_MultAdder : FC3_ena ? opr1_fc3_MultAdder : {(128 * bit){1'bz}};
    
    wire [128 * bit - 1:0] opr2_control_MultAdder;
    wire [128 * bit - 1:0] opr2_fc1_MultAdder;
    wire [128 * bit - 1:0] opr2_fc2_MultAdder;
    wire [128 * bit - 1:0] opr2_fc3_MultAdder;

    assign opr2_control_MultAdder = FC1_ena ? opr2_fc1_MultAdder : FC2_ena ? opr2_fc2_MultAdder : FC3_ena ? opr2_fc3_MultAdder : {(128 * bit){1'bz}};

    block_mem mem(
        .clka(clk),
        .ena(ena),
        .addra(addr_control_rom),
        .douta(data_rom_control)
    );

    wire [128 * bit - 1:0] data_fc1_fc2;
    full_connect1 fc1(
        .ena(FC1_ena),
        .clk(clk),
        .iRst_n(FC1_rstn),
        .data_from_rom(data_rom_fc1),
        .data_from_ram(input_image),
        .data_from_MultAdder(data_MultAdder_fc1),

        .done(FC1_done),
        .addr_to_rom(addr_fc1_rom),
        .opr1_to_MultAdder(opr1_fc1_MultAdder),
        .opr2_to_MultAdder(opr2_fc1_MultAdder),
        .data_to_ram(data_fc1_fc2)
    );

    wire [128 * bit - 1:0] data_fc2_fc3;
    
    full_connect2 fc2(
        .ena(FC2_ena),
        .clk(clk),
        .iRst_n(FC2_rstn),
        .data_from_rom(data_rom_fc2),
        .data_from_ram(data_fc1_fc2),
        .data_from_MultAdder(data_MultAdder_fc2),

        .done(FC2_done),
        .addr_to_rom(addr_fc2_rom),
        .opr1_to_MultAdder(opr1_fc2_MultAdder),
        .opr2_to_MultAdder(opr2_fc2_MultAdder),
        .data_to_ram(data_fc2_fc3)
    );

    wire [10 * bit - 1:0] data_fc3_10max;

    full_connect3 fc3(
        .ena(FC3_ena),
        .clk(clk),
        .iRst_n(FC3_rstn),
        .data_from_rom(data_rom_fc3),
        .data_from_ram(data_fc2_fc3),
        .data_from_MultAdder(data_MultAdder_fc3),

        .done(FC3_done),
        .addr_to_rom(addr_fc3_rom),
        .opr1_to_MultAdder(opr1_fc3_MultAdder),
        .opr2_to_MultAdder(opr2_fc3_MultAdder),
        .data_to_ram(data_fc3_10max)
    );

    wire [3:0] data_output;
    max_in_10 max10(
        .data_in(data_fc3_10max),
        .oIndex(data_output)
    );

    TPU_MultAdd multadd(
        .data_in1(opr1_control_MultAdder),
        .data_in2(opr2_control_MultAdder),
        .data_out(data_MultAdder_control)
    );

    always @ (posedge clk or negedge iRst_n) begin
        if (!iRst_n || !ena) begin
            status = 0;
            num_out = 4'b0; // calculating
            done = 0;
            FC1_ena = 0;
            FC2_ena = 0;
            FC3_ena = 0;
            FC1_rstn = 0;
            FC2_rstn = 0;
            FC3_rstn = 0;
        end
        else begin
            case (status)
                4'b0000: // FC1 enabled, rst
                    begin
                        status = 4'b0101;
                        FC1_ena = 1;
                        // FC1_rstn = 0;
                    end
                4'b0101: // FC1 rst done
                    begin
                        status = 4'b0001;
                        FC1_rstn = 1;
                    end
                4'b0001: // FC1 done ?
                    begin
                        if (FC1_done) begin
                            status = 4'b0010;
                            FC1_ena = 0;
                            FC1_rstn = 0;
                        end
                        else
                            status = 4'b0001;
                    end
                4'b0010: // FC2 enabled, rst
                    begin
                        status = 4'b0110;
                        FC2_ena = 1;
                        // FC2_rstn = 0;
                    end
                4'b0110: // FC2 rst done
                    begin
                        status = 4'b0011;
                        FC2_rstn = 1;
                    end
                4'b0011: // FC2 done ?
                    begin
                        if (FC2_done) begin
                            status = 4'b0111;
                            FC2_ena = 0;
                            FC2_rstn = 0;
                        end
                        else
                            status = 4'b0011;
                    end
                4'b0111: // FC3 enabled, rst
                    begin
                        status = 4'b1000;
                        FC3_ena = 1;
                        FC3_rstn = 0;
                    end
                4'b1000: // FC3 rst done
                    begin
                        status = 4'b1001;
                        FC3_rstn = 1;
                    end
                4'b1001: // FC3 done ?
                    begin
                        if (FC3_done) begin
                            status = 4'b0100;
                            FC3_ena = 0;
                            FC3_rstn = 0;
                            num_out = data_output;
                        end
                        else 
                            status = 4'b1001;
                    end
                4'b0100: // set done 
                    begin
                        done = 1;
                    end
                default: 
                    status = 4'b0000;
            endcase
        end
    end
endmodule