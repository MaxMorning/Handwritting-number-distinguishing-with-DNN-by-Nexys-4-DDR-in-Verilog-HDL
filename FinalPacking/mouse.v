//*********************************************************************************************
//PS2接收模块（鼠标发送，电脑接收）
module ps2_rx(
	input wire clk, reset,
	input wire ps2d, //ps2 data
	input wire ps2c, //ps2 clk
	input wire rx_en,

	output reg rx_done_sig,
	output wire [7:0] d_rec
);

	// symbolic state declaration
	reg [7:0] filter_reg;
	wire [7:0] filter_next;
	reg  ps2count_reg;
	wire ps2count_next;

	wire fall_edge;
	//=================================================
	// filter and falling-edge check for ps2c
	//=================================================
	always @(posedge clk)
		if (!reset) begin
			filter_reg <= 0;
			ps2count_reg <= 0;
		end
		else begin
			filter_reg <= filter_next;
			ps2count_reg <= ps2count_next;
		end

	assign filter_next = {ps2c, filter_reg[7:1]};
	assign ps2count_next = (filter_reg==8'b11111111) ? 1'b1 :(filter_reg==8'b00000000) ? 1'b0 :ps2count_reg;
	assign fall_edge = ps2count_reg & ~ps2count_next;

	/**************************************************************************************/
	/*相当于一个8位的移位寄存器，将PS_CLK的输入移入其中，即对PS_CLK连续采样超过8次，采样值都为1，
	**则此时PS_CLK处于稳定高电平，反之处于稳定的低电平，若由高到低变化，说明PS2时钟下降沿到来.
	/**************************************************************************************/
	localparam [1:0] idle = 2'b00,
				receive = 2'b01,
				done = 2'b10;
 
	reg [1:0] state_reg, state_next;
	reg [3:0]  num_reg, num_next;
	reg [10:0] data_reg, data_next;
	///////////////////////////////////////////
	always @(posedge clk)
		if (!reset) begin
			state_reg <= idle;
			num_reg <= 0;
			data_reg <= 0;
		end
		else begin
			state_reg <= state_next;
			num_reg <= num_next;
			data_reg <= data_next;
		end
	// FSMD next-state logic
	always @  ( * ) begin
		state_next = state_reg;
		num_next = num_reg;
		data_next = data_reg;

		rx_done_sig = 1'b0;

		case (state_reg)
			idle: 
				if (fall_edge & rx_en) begin
					// shift in start bit
					data_next = {ps2d, data_reg[10:1]};
					num_next = 4'd9;
					state_next = receive;
				end
			receive: // 8 data + 1 odd_parity + 1 stop
				if (fall_edge) begin
						data_next = {ps2d, data_reg[10:1]};
						if (num_reg==0)
								state_next = done;
						else
							num_next = num_reg - 1;
					end
			done: begin // 1 extra clock to complete the last shift 
				state_next = idle;
				rx_done_sig = 1'b1;
			end
		endcase
	end
	// output
	assign d_rec = data_reg[8:1]; // 接收到的数据

endmodule

`timescale 1ns / 1ps
/////////////////////////////////////
module ps2_tx(
	input wire clk, reset,
	input wire send_en,//****
	input wire [7:0] d_send,
	inout wire ps2d, ps2c,
	output reg rxen_out, tx_done_sig
);
	// symbolic state declaration
	localparam [2:0] idle = 3'b000,
					rts = 	3'b001,
					start = 3'b010,
					data = 	3'b011,
					stop = 	3'b100;
	// signal declaration
	reg [2:0] state_reg, state_next;

	reg [3:0] num_reg, num_next;
	reg [8:0] data_reg, data_next;
	reg [12:0] count_reg, count_next;

	reg ps2c_out, ps2d_out;
	reg tri_c, tri_d;
	wire odd_par;    //奇校验
	// body
	//=================================================
	// filter and falling-edge tick generation for ps2c
	//=================================================
	/*****************************************************************/
	reg H2L_F1;
	reg H2L_F2;
	
	always @ ( posedge clk or negedge reset )
		if( !reset ) begin
			H2L_F1 <= 1'b1;
			H2L_F2 <= 1'b1;
		end 
		else begin
			H2L_F1 <= ps2c;
			H2L_F2 <= H2L_F1;
		end
	
	/****************************/
	
	assign fall_edge = H2L_F2 & !H2L_F1;
	//=================================================
	//*************************************************
	/**********1. XX_reg ---> XX_next *****************
	***********2. XX_next = .......   *****************
	***********3. XX_next ---> XX_reg *****************
	**************************************************/
	//=================================================
	// FSMD state & data registers
	always @(posedge clk)
		if (!reset) begin
			state_reg <= idle;
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
	assign odd_par = ~(^d_send);    

	// FSMD next-state logic
	always @  ( * ) begin
		state_next = state_reg;

		count_next = count_reg;
		num_next = num_reg;
		data_next = data_reg;

		ps2c_out = 1'b1;
		ps2d_out = 1'b1;
		tri_c = 1'b0;
		tri_d = 1'b0;

		rxen_out = 1'b0;
		tx_done_sig = 1'b0;
		case (state_reg)
			idle: begin
				rxen_out = 1'b1;//@@@@@@@@@@@@@@@@@@@@@@@
				if (send_en) begin//**** 
					data_next = {odd_par, d_send};
					count_next = 13'h1fff; // 2^13-1 to delay 164us
					state_next = rts;  //请求发送
				end
			end
			rts: begin// request to send 
				ps2c_out = 1'b0;
				tri_c = 1'b1;
				count_next = count_reg - 1;
				if (count_reg==0)  //FPGA拉低PS2C 164us
				state_next = start;
			end
			start: begin 
				ps2d_out = 1'b0;
				tri_d = 1'b1;
				if (fall_edge) begin
					num_next = 4'h8;
					state_next = data;  
				end
			end
			data: begin// 8 data + 1 odd_parity 
				ps2d_out = data_reg[0];
				tri_d = 1'b1;
				if (fall_edge) begin
					data_next = {1'b0, data_reg[8:1]};
					if (num_reg == 0)
						state_next = stop;
					else
						num_next = num_reg - 1;
				end
			end
	//**************************************
			stop: // assume floating high for ps2d
			if (fall_edge) begin
				state_next = idle;
				tx_done_sig = 1'b1;
			end
		endcase
	end
	// tri-state buffers
	assign ps2c = (tri_c) ? ps2c_out : 1'bz;
	assign ps2d = (tri_d) ? ps2d_out : 1'bz;
endmodule


//******************************************************************************************************
//双向通信模块
`timescale 1ns / 1ps
////////////////////////////////////
module ps2_rxtx(
	input wire clk, reset,
	input wire send_en,//****
	inout wire ps2d, ps2c,
	input wire [7:0] d_send,

	output wire rx_done_sig, tx_done_sig,
	output wire [7:0] d_rec
);
	// signal declaration
	wire rxen_out;

	// body
	// instantiate ps2 receiver
	ps2_rx ps2_rx_unit(
		.clk(clk), 
		.reset(reset), 
		.rx_en(rxen_out),
		.ps2d(ps2d), 
		.ps2c(ps2c),
		.rx_done_sig(rx_done_sig), 
		.d_rec(d_rec)
	);
	// instantiate ps2 transmitter
	ps2_tx ps2_tx_unit(
		.clk(clk), 
		.reset(reset), 
		.send_en(send_en),
		.d_send(d_send), 
		.ps2d(ps2d), 
		.ps2c(ps2c),
		.rxen_out(rxen_out), 
		.tx_done_sig(tx_done_sig)
	);

endmodule

//*************************************************************************************************************
//**************************************鼠标接口电路模块**********************************
`timescale 1ns / 1ps
////////////////////////////////
module mouse(
	input wire clk, reset,
	inout wire ps2d, ps2c,
	output wire [8:0] xm, ym,
	output wire [2:0] button,
	output reg done_sig,
	output wire send_en_out
);
	// constant declaration
	localparam STRM=8'hf4; // stream command F4
	// symbolic state declaration
	localparam [2:0]
	init1 = 3'b000,
	init2 = 3'b001,
	init3 = 3'b010,
	pack1 = 3'b011,
	pack2 = 3'b100,
	pack3 = 3'b101,
	done = 3'b110,
	pack4 = 3'b111;
	// signal declaration
	reg [2:0] state_reg, state_next;
	wire [7:0] rx_data;
	reg send_en;//**
	wire rx_done_sig, tx_done_sig;
	reg [8:0] x_reg, y_reg, x_next, y_next;
	reg [2:0] button_reg, button_next;

	// body
	// instantiation
	ps2_rxtx ps2_unit(
		.clk(clk), 
		.reset(reset), 
		.send_en(send_en_out),
		.d_send(STRM), 
		.d_rec(rx_data), 
		.ps2d(ps2d), 
		.ps2c(ps2c),
		.rx_done_sig(rx_done_sig),
		.tx_done_sig(tx_done_sig)
	);
	// body
	// FSMD state and data registers
	always @(posedge clk)
		if (!reset) begin
			state_reg <= init1;
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
	// FSMD next-state logic
	always @  ( * ) begin
		state_next = state_reg;

		send_en = 1'b0;     //@@@@
		done_sig = 1'b0;

		x_next = x_reg;
		y_next = y_reg;
		button_next = button_reg;

		case (state_reg)
			init1: begin
				send_en = 1'b1;      //@@@@@
				state_next = init2;
			end
			init2: // wait for send to complete
				if (tx_done_sig)
					state_next = init3;
			init3: // wait for acknowledge packet
				if (rx_done_sig)
					state_next = pack1;
			pack1: // wait for 1st data packet
				if (rx_done_sig) begin
					state_next = pack2;
					y_next[8] = rx_data[5];
					x_next[8] = rx_data[4];
					button_next = rx_data[2:0];
					end
			pack2: // wait for 2nd data packet
			if (rx_done_sig) begin
				state_next = pack3;
				x_next[7:0] = rx_data;
			end
			pack3: // wait for 3rd data packet
			if (rx_done_sig) begin
				state_next = pack4;
				y_next[7:0] = rx_data;
				end
		    pack4:
		    if (rx_done_sig) begin
		        state_next = done;
		    end
			done: begin
				done_sig = 1'b1;
				state_next = pack1;
			end
		endcase
	end


	// output
	assign xm = x_reg;
	assign ym = y_reg;
	assign button = button_reg;
	assign send_en_out=send_en;
endmodule
