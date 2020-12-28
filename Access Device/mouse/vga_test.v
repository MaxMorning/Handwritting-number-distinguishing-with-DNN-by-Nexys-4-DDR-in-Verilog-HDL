module vga_test(
    input iBusClk, // Bus Clock
    input iRstN, // Async reset signal
    inout ps2clk, // ps2 Clock Bus
    inout ps2data, // ps2 Data Bus
    output reg [3:0] oRed, // red signal
    output reg [3:0] oGreen, // green signal
    output reg [3:0] oBlue, // blue signal
    output oHs, // Hori sync
    output oVs // Vert sync
);

    // 800 * 600
    parameter   C_H_SYNC_PULSE   = 128, 
                C_H_BACK_PORCH   = 88,
                C_H_ACTIVE_TIME  = 800,
                C_H_FRONT_PORCH  = 40,
                C_H_LINE_PERIOD  = 1056;
    
    parameter   C_V_SYNC_PULSE   = 4, 
                C_V_BACK_PORCH   = 23,
                C_V_ACTIVE_TIME  = 600,
                C_V_FRONT_PORCH  = 1,
                C_V_FRAME_PERIOD = 628;

    reg [10:0] hCnt; // Hori Counter
    reg [10:0] vCnt; // Vert Counter
    wire clkVga; // VGA clock, 40MHz
    wire isActive;
    
    
    //reg [11:0] image [799:0][599:0];

//    clk_wiz_40m clk_inst
//   (
//        .clk_in1(iBusClk),
//        .clk_out1(clkVga),
//        .resetn(iRstN) // input resetn
//    );
    
    wire mouseClk;
    
    clk_wiz_0 clk_inst(
        .clk_in1(iBusClk),
        .clk_out1(mouseClk),
        .clk_out2(clkVga),
        .resetn(iRstN)
    );
    
    reg [15:0] cursor_x = 0;
    reg [15:0] cursor_y = 0;
    reg [2:0]  but_stat;
    wire [8:0] mouse_x;
    wire [8:0] mouse_y;
    wire [2:0] button;
    wire done_sig;
    
    wire [15:0] x_next;
    wire [15:0] y_next;
    wire [2:0] b_next;
    
    wire [7:0] x_abs;
    wire [7:0] y_abs;
    
    assign x_abs = (mouse_x[8] == 1'b0) ? mouse_x[7:0] : ~(mouse_x[7:0] + 1);
    assign y_abs = (mouse_y[8] == 1'b0) ? mouse_y[7:0] : ~(mouse_y[7:0] + 1);

    assign x_next = (~done_sig) ? cursor_x : (mouse_x[8] == 0) ? ((cursor_x +  x_abs > 16'b1111111110000000) ? 16'b1111111110000000 : cursor_x + x_abs) : ((cursor_x >= x_abs) ? cursor_x - x_abs : 0);
    assign y_next = (~done_sig) ? cursor_y : (mouse_y[8] == 0) ? ((cursor_y +  y_abs > 16'b1111111110000000) ? 16'b1111111110000000 : cursor_y + y_abs) : ((cursor_y >= y_abs) ? cursor_y - y_abs : 0);
    assign b_next = (~done_sig) ? 3'b000 : but_stat;
    always @ ( * ) begin
        if (!iRstN) begin
            cursor_x <= 0;
            cursor_y <= 0;
            but_stat <= 0;
        end
        else begin
            cursor_x <= x_next;
            cursor_y <= y_next;
            but_stat <= b_next;
        end
    end
        
//    assign cursor_x = mouse_x;
//    assign cursor_y = mouse_y;
    mouse mouse_inst(
        .clk(mouseClk),
        .reset(iRstN),
        .ps2d(ps2data),
        .ps2c(ps2clk),
        .xm(mouse_x),
        .ym(mouse_y),
        .button(button),
        .done_sig(done_sig)
    );
//    ps2_mouse_xy(
//        .clk(mouseClk),
//        .reset(~iRstN),
//        .ps2_clk(ps2clk),
//        .ps2_data(ps2data),
//        .mx(cursor_x),
//        .my(cursor_y),
//        .btn_click(but_stat)
//    );
//    assign clkVga = iBusClk;
    // Hori
    always @ (posedge clkVga or negedge iRstN) begin
        if (!iRstN || hCnt == C_H_LINE_PERIOD - 1)
            hCnt <= 11'd0;
        else
            hCnt <= hCnt + 1;
    end

    assign oHs = (hCnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1;


    //Vert
    always @ (posedge oHs or negedge iRstN) begin
        if (!iRstN || vCnt == C_V_FRAME_PERIOD - 1)
            vCnt <= 11'd0;
        else
            vCnt <= vCnt + 1;
    end

    assign oVs = (vCnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1;

    assign isActive =   (hCnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                  ))  &&
                        (hCnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME))  && 
                        (vCnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                  ))  &&
                        (vCnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME))  ;

    always @ (posedge clkVga or negedge iRstN) begin
        if (!iRstN) begin
            oRed <= 4'b0000;
            oGreen <= 4'b0000;
            oBlue <= 4'b0000;
        end
        else if (isActive) begin
            if (hCnt - (C_H_SYNC_PULSE + C_H_BACK_PORCH) <= y_next[15: 7] + 8 && hCnt - (C_H_SYNC_PULSE + C_H_BACK_PORCH) >= y_next[15:7] && vCnt - (C_V_SYNC_PULSE + C_V_BACK_PORCH) <= x_next[15:7] + 8 && vCnt - (C_V_SYNC_PULSE + C_V_BACK_PORCH) >= x_next[15:7]) begin
//            if (hCnt - (C_H_SYNC_PULSE + C_H_BACK_PORCH) <= 240 && hCnt - (C_H_SYNC_PULSE + C_H_BACK_PORCH) >= 160) begin
                if (button[0]) begin
                    oRed <= 4'b0000;
                    oBlue <= 4'b0000;
                    oGreen <= 4'b1111;
                end
                else if (button[1]) begin
                    oRed <= 4'b0000;
                    oBlue <= 4'b1111;
                    oGreen <= 4'b0000;
                end
                else begin
                    oRed <= 4'b1111;
                    oBlue <= 4'b1111;
                    oGreen <= 4'b1111;
                end
            end
            else begin
                oRed <= 4'b1111;
                oGreen <= 4'b0000;
                oBlue <= 4'b0000;
            end
        end
        else begin
            oRed <= 4'b0000;
            oGreen <= 4'b0000;
            oBlue <= 4'b0000;
        end
    end
endmodule