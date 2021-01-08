module total_control(
    // general
    input sysClk,

    //user button
    input iRst_n,
    input confirm,
    
    //mouse io
    inout ps2clk,
    inout ps2data,

    // vga interface
    output [3:0] oRed,
    output [3:0] oGreen,
    output [3:0] oBlue,
    output oHs,
    output oVs,
    // 7 seg display interface
    output [6:0] num_display,

    // light interface
    output reg done
);

    wire mouseClk, clkVga, TPU_clk;
    clk_wiz_0 clk_inst(
        .clk_in1(sysClk),
        .clk_out1(mouseClk), // 5MHz?
        .clk_out2(clkVga), // 40MHz
        .clk_out3(TPU_clk), // 49.231MHz
        .resetn(iRst_n)
    );

    reg vga_rstn;
    wire [32 * 32 - 1:0] user_image;
    vga_module vga_inst(
        .iBusClk(sysClk),
        .mouseClk(mouseClk),
        .clkVga(clkVga),
        .iRstN(vga_rstn),
        .ps2clk(ps2clk),
        .ps2data(ps2data),
        .oRed(oRed),
        .oGreen(oGreen),
        .oBlue(oBlue),
        .oHs(oHs),
        .oVs(oVs),
        .image(user_image)
    );

    reg TPU_ena;
    reg TPU_rstn;
    wire [3:0] num_out;
    reg [32 * 32 - 1:0] in_image;
    wire TPU_done;
    TPU_Control tpu_inst(
        .clk(TPU_clk),
        .ena(TPU_ena),
        .iRst_n(TPU_rstn),
        .input_image(in_image),

        .num_out(num_out),
        .done(TPU_done)
    );

    reg display7_ena;
    display7 disp_inst(
        .ena(display7_ena),
        .iData(num_out),
        .oData(num_display)
    );

    reg [2:0] status;
    reg [9:0] delayCnt;
    reg [10:0] i;
    always @ (posedge TPU_clk or negedge iRst_n) begin
        if (!iRst_n) begin
            status <= 3'b000;
            TPU_ena <= 0;
            display7_ena <= 0;
            vga_rstn <= 1;
            TPU_rstn <= 1;
            delayCnt <= 0;
            done <= 0;
        end
        else begin
            case (status)
                3'b000: // reset
                    begin
                        status = 3'b001;
                        vga_rstn = 0;
                    end
                3'b001: // reset done
                    if (delayCnt > 1000)
                    begin
                        status = 3'b010;
                        vga_rstn = 1;
                    end
                    else
                        delayCnt = delayCnt + 1;
                3'b010: // draw
                    begin
                        if (confirm) begin
                            status = 3'b011;
                            in_image = user_image;
                            TPU_ena = 1;
                            TPU_rstn = 0;
                        end
                        else
                            status = 3'b010;
                    end
                3'b011: // wait for TPU initial
                    status = 3'b110; 
                3'b110: // TPU initial done
                    begin
                        status = 3'b100;
                        TPU_rstn = 1;
                    end

                3'b100: // TPU Calculating , waiting
                    begin
                        if (TPU_done) begin
                            status = 3'b101;
                            display7_ena = 1;
                            // TPU_ena = 0;
                        end
                        else
                            status = 3'b100;
                    end
                3'b101: // display result
                    begin
                       status = 3'b101;
                       done = 1;
                    end
                default: 
                    status = 3'b000;
            endcase
        end
    end
endmodule