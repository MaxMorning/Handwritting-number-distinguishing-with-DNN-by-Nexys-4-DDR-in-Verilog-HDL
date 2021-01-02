module total_control(
    // general
    input sysClk,

    //user button
    input iRst_n,
    input confirm,
    input clear,
    
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
    output wire overflow,
    output wire done
);

    wire mouseClk, clkVga;
    clk_wiz_0 clk_inst(
        .clk_in1(sysClk),
        .clk_out1(mouseClk), // 5MHz?
        .clk_out2(clkVga), // 40MHz
        .resetn(iRst_n)
    );

    reg vga_ena;
    reg vga_rstn;
    wire [32 * 32 - 1:0] user_image;
    vga_module vga_inst(
        .iBusClk(sysClk),
        .ena(vga_ena),
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
    TPU_Control tpu_inst(
        .clk(sysClk),
        .ena(TPU_ena),
        .iRst_n(TPU_rstn),
        .input_image(user_image),

        .num_out(num_out),
        .overflow(overflow),
        .done(done)
    );

    reg display7_ena;
    display7 disp_inst(
        .ena(display7_ena),
        .iData(num_out),
        .oData(num_display)
    );

    reg [2:0] status;

    always @ (posedge sysClk) begin
        if (!iRst_n) begin
            status <= 3'b000;
            vga_ena <= 0;
            TPU_ena <= 0;
            display7_ena <= 0;
            vga_rstn <= 1;
            TPU_rstn <= 1;
        end
        else begin
            case (status)
                3'b000: // reset
                    begin
                        status <= 3'b001;
                        vga_ena = 1;
                        vga_rstn = 0;
                    end
                3'b001: // reset done
                    begin
                        status <= 3'b010;
                        vga_rstn = 1;
                    end
                3'b010: // draw
                    begin
                        if (clear) begin
                            status <= 3'b000;
                        end
                        else if (confirm) begin
                            status <= 3'b110;
                            TPU_ena = 1;
                            TPU_rstn = 0;
                        end
                        else
                            status <= 3'b010;
                    end
                3'b110: // TPU initial done
                    begin
                        status <= 3'b100;
                        TPU_rstn <= 1;
                    end
                // 3'b011: // TPU Calc

                3'b100: // TPU Calculating , waiting
                    begin
                        if (done) begin
                            status <= 3'b101;
                            display7_ena <= 1;
                        end
                        else
                            status <= 3'b100;
                    end
                3'b101: // display result
                    begin
                        if (clear)
                            status <= 3'b000;
                        else
                            status <= 3'b101;
                    end
                default: 
                    status <= 3'b000;
            endcase
        end
    end
endmodule