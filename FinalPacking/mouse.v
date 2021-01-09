module ps2_rx(
    input clk,
    input reset,
    input ps2data,
    input ps2clk,
    input rx_en,

    output reg rx_done_sig,
    output [7:0] data_rec
);

    reg [7:0] filter_reg;
    wire [7:0] filter_next;
    reg  ps2count_reg;
    wire ps2count_next;

    wire fall_edge;

    always @(posedge clk)
        if (!reset) begin
            filter_reg <= 0;
            ps2count_reg <= 0;
        end
        else begin
            filter_reg <= filter_next;
            ps2count_reg <= ps2count_next;
        end

    assign filter_next = {ps2clk, filter_reg[7:1]};
    assign ps2count_next = (filter_reg == 8'b11111111) ? 1'b1 : (filter_reg == 8'b00000000) ? 1'b0 : ps2count_reg;
    assign fall_edge = ps2count_reg & ~ps2count_next;
 
    reg [1:0] state_reg, state_next;
    reg [3:0]  num_reg, num_next;
    reg [10:0] data_reg, data_next;

    always @(posedge clk)
        if (!reset) begin
            state_reg <= 2'b00;
            num_reg <= 0;
            data_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            num_reg <= num_next;
            data_reg <= data_next;
        end

    always @  ( * ) begin
        state_next = state_reg;
        num_next = num_reg;
        data_next = data_reg;

        rx_done_sig = 1'b0;

        case (state_reg)
            2'b00: // idle
                if (fall_edge & rx_en) begin
                    data_next = {ps2data, data_reg[10:1]};
                    num_next = 4'd9;
                    state_next = 2'b01;
                end
            2'b01: //receive , 8 data + 1 odd_parity + 1 stop
                if (fall_edge) begin
                        data_next = {ps2data, data_reg[10:1]};
                        if (num_reg == 0)
                                state_next = 2'b10;
                        else
                            num_next = num_reg - 1;
                    end
            2'b10: begin // done
                state_next = 2'b00;
                rx_done_sig = 1'b1;
            end
        endcase
    end
    // output
    assign data_rec = data_reg[8:1];

endmodule

`timescale 1ns / 1ps

module ps2_tx(
    input clk, 
    input reset,
    input send_en,
    input [7:0] data_send,
    inout ps2data,
    inout ps2clk,
    output reg rxen_out,
    output reg tx_done_sig
);
    reg [2:0] state_reg, state_next;

    reg [3:0] num_reg, num_next;
    reg [8:0] data_reg, data_next;
    reg [12:0] count_reg, count_next;

    reg ps2clk_out, ps2data_out;
    reg clk_oena, data_oena;
    wire odd_par;

    // key-vibration eliminate ?
    reg H2L_F1;
    reg H2L_F2;

    assign ps2clk = clk_oena ? ps2clk_out : 1'bz;
    assign ps2data = data_oena ? ps2data_out : 1'bz;

    always @ ( posedge clk or negedge reset )
        if( !reset ) begin
            H2L_F1 <= 1'b1;
            H2L_F2 <= 1'b1;
        end 
        else begin
            H2L_F1 <= ps2clk;
            H2L_F2 <= H2L_F1;
        end
    
    
    assign fall_edge = H2L_F2 & !H2L_F1;

    always @(posedge clk)
        if (!reset) begin
            state_reg <= 3'b000;
            count_reg <= 0;
            num_reg <= 0;
            data_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            count_reg <= count_next;
            num_reg <= num_next;
            data_reg <= data_next;
        end
    assign odd_par = ~(^data_send);    

    always @  ( * ) begin
        state_next = state_reg;

        count_next = count_reg;
        num_next = num_reg;
        data_next = data_reg;

        ps2clk_out = 1'b1;
        ps2data_out = 1'b1;
        clk_oena = 1'b0;
        data_oena = 1'b0;

        rxen_out = 1'b0;
        tx_done_sig = 1'b0;
        case (state_reg)
            3'b000: begin // idle
                rxen_out = 1'b1;
                if (send_en) begin
                    data_next = {odd_par, data_send};
                    count_next = 13'h1fff; // delay
                    state_next = 3'b001; 
                end
            end
            3'b001: begin// prepare to send 
                ps2clk_out = 1'b0;
                clk_oena = 1'b1;
                count_next = count_reg - 1;
                if (count_reg==0)
                    state_next = 3'b010;
            end
            3'b010: begin // start
                ps2data_out = 1'b0;
                data_oena = 1'b1;
                if (fall_edge) begin
                    num_next = 4'h8;
                    state_next = 3'b011;  
                end
            end
            3'b011: begin// send data
                ps2data_out = data_reg[0];
                data_oena = 1'b1;
                if (fall_edge) begin
                    data_next = {1'b0, data_reg[8:1]};
                    if (num_reg == 0)
                        state_next = 3'b100;
                    else
                        num_next = num_reg - 1;
                end
            end
            3'b100: // stop
            if (fall_edge) begin
                state_next = 3'b000;
                tx_done_sig = 1'b1;
            end
        endcase
    end

endmodule


`timescale 1ns / 1ps
module ps2_rxtx(
    input clk,
    input reset,
    input send_en,
    inout ps2data,
    inout ps2clk,
    input [7:0] data_send,

    output rx_done_sig,
    output tx_done_sig,
    output [7:0] data_rec
);
    wire rxen_out;

    ps2_rx ps2_rx_unit(
        .clk(clk), 
        .reset(reset), 
        .rx_en(rxen_out),
        .ps2data(ps2data), 
        .ps2clk(ps2clk),
        .rx_done_sig(rx_done_sig), 
        .data_rec(data_rec)
    );
    ps2_tx ps2_tx_unit(
        .clk(clk), 
        .reset(reset), 
        .send_en(send_en),
        .data_send(data_send), 
        .ps2data(ps2data), 
        .ps2clk(ps2clk),
        .rxen_out(rxen_out), 
        .tx_done_sig(tx_done_sig)
    );

endmodule

`timescale 1ns / 1ps

module mouse(
    input clk,
    input reset,
    inout ps2data,
    inout ps2clk,
    output [8:0] xm,
    output [8:0] ym,
    output [2:0] button,
    output reg done_sig
);
    wire send_en_out;
    reg [2:0] state_reg, state_next;
    wire [7:0] rx_data;
    reg send_en;
    wire rx_done_sig, tx_done_sig;
    reg [8:0] x_reg, y_reg, x_next, y_next;
    reg [2:0] button_reg, button_next;

    assign xm = x_reg;
    assign ym = y_reg;
    assign button = button_reg;
    assign send_en_out = send_en;

    ps2_rxtx ps2_unit(
        .clk(clk), 
        .reset(reset), 
        .send_en(send_en_out),
        .data_send(8'hf4), 
        .data_rec(rx_data), 
        .ps2data(ps2data), 
        .ps2clk(ps2clk),
        .rx_done_sig(rx_done_sig),
        .tx_done_sig(tx_done_sig)
    );

    always @(posedge clk)
        if (!reset) begin
            state_reg <= 3'b000;
            x_reg <= 0;
            y_reg <= 0;
            button_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            x_reg <= x_next;
            y_reg <= y_next;
            button_reg <= button_next;
        end

    always @  ( * ) begin
        state_next = state_reg;

        send_en = 1'b0;
        done_sig = 1'b0;

        x_next = x_reg;
        y_next = y_reg;
        button_next = button_reg;

        case (state_reg)
            3'b000: begin // init
                send_en = 1'b1;
                state_next = 3'b001;
            end
            3'b001: // wait for send to complete
                if (tx_done_sig)
                    state_next = 3'b010;
            3'b010: // wait for acknowledge packet
                if (rx_done_sig)
                    state_next = 3'b011;
            3'b011: // wait for 1st data packet
                if (rx_done_sig) begin
                    state_next = 3'b100;
                    y_next[8] = rx_data[5];
                    x_next[8] = rx_data[4];
                    button_next = rx_data[2:0];
                    end
            3'b100: // wait for 2nd data packet
            if (rx_done_sig) begin
                state_next = 3'b101;
                x_next[7:0] = rx_data;
            end
            3'b101: // wait for 3rd data packet
            if (rx_done_sig) begin
                state_next = 3'b111;
                y_next[7:0] = rx_data;
                end
            3'b111:
            if (rx_done_sig) begin
                state_next = 3'b110;
            end
            3'b110: begin // done
                done_sig = 1'b1;
                state_next = 3'b011;
            end
        endcase
    end
endmodule
