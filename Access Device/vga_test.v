module vga_test(
    input iBusClk, // Bus Clock
    input iRstN, // Async reset signal
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

    clk_wiz_40m clk_inst
   (
        .clk_in1(iBusClk),
        .clk_out1(clkVga),
        .resetn(iRstN), // input resetn
        .locked()
    );
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
            oRed <= hCnt / 50;
            oBlue <= hCnt / 50;
            oGreen <= hCnt / 50;
//            oRed <= 4'b1111;
//            oGreen <= 4'b0000;
//            oGreen <= 4'b0011;
//            oBlue <= 4'b0000;
//            oRed <= image[hCnt][vCnt][3:0];
//            oGreen <= image[hCnt][vCnt][7:4];
//            oBlue <= image[hCnt][vCnt][11:8];
        end
        else begin
            oRed <= 4'b0000;
            oGreen <= 4'b1111;
        end
    end
endmodule