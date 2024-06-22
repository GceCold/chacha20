`timescale  1ns / 1ps
module chacha20 #(
    parameter AXI_IDWIDTH = 4
) (
    // System clock
    input  wire                   aclk,
    input  wire                   areset_n,
    // AXI-STREAM input data interface
    output wire                   i_axis_tready,
    input  wire                   i_axis_tvalid,
    input  wire [           31:0] i_axis_tdata,
    // AXI-MM AW interface
    output wire                   s_axi_awready,
    input  wire                   s_axi_awvalid,
    input  wire [           63:0] s_axi_awaddr,
    input  wire [            7:0] s_axi_awlen,
    input  wire [AXI_IDWIDTH-1:0] s_axi_awid,
    // AXI-MM W  interface
    output wire                   s_axi_wready,
    input  wire                   s_axi_wvalid,
    input  wire                   s_axi_wlast,
    input  wire [           64:0] s_axi_wdata,
    // AXI-MM B  interface
    input  wire                   s_axi_bready,
    output wire                   s_axi_bvalid,
    output wire [AXI_IDWIDTH-1:0] s_axi_bid,
    output wire [            1:0] s_axi_bresp,
    // AXI-STREAM output data interface
    input  wire                   o_axis_tready,
    output reg                    o_axis_tvalid,
    output reg  [           31:0] o_axis_tdata,
    // IP state interface
    input  wire                   init_data_finish,
    output wire                   outdate_key

);

    localparam AXI_W_IDLE = 2'b00;
    localparam AXI_W_BUSY = 2'b01;
    localparam AXI_W_RESP = 2'b11;

    reg  [            1:0] wstate = AXI_W_IDLE;
    reg  [AXI_IDWIDTH-1:0] wid = 'b0;
    reg  [            7:0] wcount = 'b0;
    reg  [         63-3:0] waddr_63_3 = 'b0;
    wire [           63:0] waddr = {waddr_63_3, 3'h0};

    assign s_axi_awready = (wstate == AXI_W_IDLE);
    assign s_axi_wready  = (wstate == AXI_W_BUSY);
    assign s_axi_bvalid  = (wstate == AXI_W_RESP);
    assign s_axi_bid     = wid;
    assign s_axi_bresp   = 'b0;

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n) begin
            wstate     <= AXI_W_IDLE;
            wid        <= 'b0;
            wcount     <= 'b0;
            waddr_63_3 <= 'b0;
        end
        else begin
            case (wstate)
                AXI_W_IDLE:
                if (s_axi_awvalid) begin
                    wstate     <= AXI_W_BUSY;
                    wid        <= s_axi_awid;
                    wcount     <= s_axi_awlen;
                    waddr_63_3 <= s_axi_awaddr[63:3];
                end
                AXI_W_BUSY:
                if (s_axi_wvalid) begin
                    if (wcount == 8'd0 || s_axi_wlast) wstate <= AXI_W_RESP;
                    wcount     <= wcount - 8'd1;
                    waddr_63_3 <= waddr_63_3 + 61'h1;
                end
                AXI_W_RESP: if (s_axi_bready) wstate <= AXI_W_IDLE;
                default:    wstate <= AXI_W_IDLE;
            endcase
        end
    end



    localparam IDLE                 = 4'b0000;
    localparam WAIT_INIT            = 4'b0001;
    localparam QUARTERROUND_PRE     = 4'b0011;
    localparam QUARTERROUND         = 4'b0110;
    localparam START_SERIALIZE_PRE  = 4'b0111;
    localparam SERIALIZE            = 4'b0101;
    localparam FINISH               = 4'b0100;

    reg  [ 3:0] round_count;
    reg  [ 4:0] serialize_count;
    reg         qr_state;
    reg  [ 2:0] state;
    reg  [ 2:0] next_state;
    reg         init_data;
    reg         init_data_finish_reg;
    wire        init_data_finish_pos;

    wire        origin_data_fifo_full;
    wire [ 9:0] origin_data_fifo_data_count;
    wire        origin_data_fifo_data_wr_rst_busy;
    wire        origin_data_fifo_data_rd_rst_busy;
    wire [31:0] origin_data_fifo_data;
    wire        origin_data_fifo_empty;
    reg         origin_data_fifo_rd_en;

    wire [31:0] result_data_fifo_data;
    wire        result_data_fifo_empty;
    wire [ 9:0] result_data_fifo_data_count;
    reg         result_data_fifo_rd_en;
    wire        result_data_fifo_wr_rst_busy;
    wire        result_data_fifo_rd_rst_busy;

    reg  [31:0] serialize_result;
    reg         serialize_result_valid;

    // reg  [31:0] block_32                          [15:0];
    reg  [31:0] counter;

    reg  [31:0] block_32_0;
    reg  [31:0] block_32_1;
    reg  [31:0] block_32_2;
    reg  [31:0] block_32_3;
    reg  [31:0] block_32_4;
    reg  [31:0] block_32_5;
    reg  [31:0] block_32_6;
    reg  [31:0] block_32_7;
    reg  [31:0] block_32_8;
    reg  [31:0] block_32_9;
    reg  [31:0] block_32_10;
    reg  [31:0] block_32_11;
    reg  [31:0] block_32_12;
    reg  [31:0] block_32_13;
    reg  [31:0] block_32_14;
    reg  [31:0] block_32_15;

    reg  [31:0] origin_block_32_0;
    reg  [31:0] origin_block_32_1;
    reg  [31:0] origin_block_32_2;
    reg  [31:0] origin_block_32_3;
    reg  [31:0] origin_block_32_4;
    reg  [31:0] origin_block_32_5;
    reg  [31:0] origin_block_32_6;
    reg  [31:0] origin_block_32_7;
    reg  [31:0] origin_block_32_8;
    reg  [31:0] origin_block_32_9;
    reg  [31:0] origin_block_32_10;
    reg  [31:0] origin_block_32_11;
    reg  [31:0] origin_block_32_12;
    reg  [31:0] origin_block_32_13;
    reg  [31:0] origin_block_32_14;
    reg  [31:0] origin_block_32_15;

    assign init_data_finish_pos = init_data_finish & (~init_data_finish_reg);
    assign outdate_key          = ~init_data;
    assign i_axis_tready         = init_data & ~origin_data_fifo_full & ~origin_data_fifo_data_wr_rst_busy;


    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n) 
            init_data_finish_reg <= 1'b0;
        else 
            init_data_finish_reg <= init_data_finish;
    end

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n) 
            init_data <= 1'b0;
        else begin
            if (init_data_finish_reg && ~init_data) 
                init_data <= 1'b1;
            else if (init_data && counter == 32'hffff_ffff) 
                init_data <= 1'b0;
        end
    end

    always @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            origin_block_32_0 <= 32'd0;
            origin_block_32_1 <= 32'd0;
            origin_block_32_2 <= 32'd0;
            origin_block_32_3 <= 32'd0;
            origin_block_32_4 <= 32'd0;
            origin_block_32_5 <= 32'd0;
            origin_block_32_6 <= 32'd0;
            origin_block_32_7 <= 32'd0;
            origin_block_32_8 <= 32'd0;
            origin_block_32_9 <= 32'd0;
            origin_block_32_10<= 32'd0;
            origin_block_32_11<= 32'd0;
            origin_block_32_12<= 32'd0;
            origin_block_32_13<= 32'd0;
            origin_block_32_14<= 32'd0;
            origin_block_32_15<= 32'd0;
        end
        else if(init_data_finish_pos) begin
            origin_block_32_0 <= block_32_0 ;
            origin_block_32_1 <= block_32_1 ;
            origin_block_32_2 <= block_32_2 ;
            origin_block_32_3 <= block_32_3 ;
            origin_block_32_4 <= block_32_4 ;
            origin_block_32_5 <= block_32_5 ;
            origin_block_32_6 <= block_32_6 ;
            origin_block_32_7 <= block_32_7 ;
            origin_block_32_8 <= block_32_8 ;
            origin_block_32_9 <= block_32_9 ;
            origin_block_32_10<= block_32_10;
            origin_block_32_11<= block_32_11;
            origin_block_32_12<= block_32_12;
            origin_block_32_13<= block_32_13;
            origin_block_32_14<= block_32_14;
            origin_block_32_15<= block_32_15;
        end
        else if(state == FINISH) begin
            origin_block_32_12  <=  origin_block_32_12 + 1;
        end
    end

    always @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            qr_state <= 1'b0;
            round_count <=  4'b0;
            counter     <= 'b0;

            //"expand 32-byte k"
            //https://datatracker.ietf.org/doc/html/rfc7539    Page7
            block_32_0 <= 32'h61707865;
            block_32_1 <= 32'h3320646e;
            block_32_2 <= 32'h79622d32;
            block_32_3 <= 32'h6b206574;
            block_32_4 <= 32'd0;
            block_32_5 <= 32'd0;
            block_32_6 <= 32'd0;
            block_32_7 <= 32'd0;
            block_32_8 <= 32'd0;
            block_32_9 <= 32'd0;
            block_32_10<= 32'd0;
            block_32_11<= 32'd0;
            block_32_12<= 32'd0;
            block_32_13<= 32'd0;
            block_32_14<= 32'd0;
            block_32_15<= 32'd0;
        end
        else if (s_axi_wvalid & s_axi_wready) begin
            if (waddr == 64'h00000000) begin  // address  = 0x00000000 : {key[1],key[0]}
                block_32_4 <= s_axi_wdata[31:0];
                block_32_5 <= s_axi_wdata[63:32];
            end
            else if (waddr == 64'h00000010) begin  // address  = 0x00000010 : {key[3],key[2]}
                block_32_6 <= s_axi_wdata[31:0];
                block_32_7 <= s_axi_wdata[63:32];
            end
            else if (waddr == 64'h00000020) begin  // address  = 0x00000020 : {key[5],key[4]}
                block_32_8 <= s_axi_wdata[31:0];
                block_32_9 <= s_axi_wdata[63:32];
            end
            else if (waddr == 64'h00000030) begin  // address  = 0x00000030 : {key[7],key[6]}
                block_32_10 <= s_axi_wdata[31:0];
                block_32_11 <= s_axi_wdata[63:32];
            end
            else if (waddr == 64'h00000040) begin  // address  = 0x00000040 : {nonce[0],block_counter}
                counter     <= s_axi_wdata[31:0];
                block_32_12 <= s_axi_wdata[31:0];
                block_32_13 <= s_axi_wdata[63:32];
            end
            else if (waddr == 64'h00000050) begin  // address  = 0x00000050 : {nonce[2],nonce[1]}
                block_32_14 <= s_axi_wdata[31:0];
                block_32_15 <= s_axi_wdata[63:32];
            end
        end
        else if (state == QUARTERROUND_PRE) begin
            block_32_0  <= origin_block_32_0 ;
            block_32_1  <= origin_block_32_1 ;
            block_32_2  <= origin_block_32_2 ;
            block_32_3  <= origin_block_32_3 ;
            block_32_4  <= origin_block_32_4 ;
            block_32_5  <= origin_block_32_5 ;
            block_32_6  <= origin_block_32_6 ;
            block_32_7  <= origin_block_32_7 ;
            block_32_8  <= origin_block_32_8 ;
            block_32_9  <= origin_block_32_9 ;
            block_32_10 <= origin_block_32_10;
            block_32_11 <= origin_block_32_11;
            block_32_12 <= origin_block_32_12;
            block_32_13 <= origin_block_32_13;
            block_32_14 <= origin_block_32_14;
            block_32_15 <= origin_block_32_15;
        end
        else if (state == QUARTERROUND) begin
            if (round_count <= 4'd9) begin
                if (~qr_state) begin
                    {block_32_0, block_32_4, block_32_8 , block_32_12}  <= quarterround(block_32_0, block_32_4, block_32_8 , block_32_12);
                    {block_32_1, block_32_5, block_32_9 , block_32_13}  <= quarterround(block_32_1, block_32_5, block_32_9 , block_32_13);
                    {block_32_2, block_32_6, block_32_10, block_32_14}  <= quarterround(block_32_2, block_32_6, block_32_10, block_32_14);
                    {block_32_3, block_32_7, block_32_11, block_32_15}  <= quarterround(block_32_3, block_32_7, block_32_11, block_32_15);
                end
                else begin
                    {block_32_0, block_32_5, block_32_10, block_32_15}  <= quarterround(block_32_0, block_32_5, block_32_10, block_32_15);
                    {block_32_1, block_32_6, block_32_11, block_32_12}  <= quarterround(block_32_1, block_32_6, block_32_11, block_32_12);
                    {block_32_2, block_32_7, block_32_8 , block_32_13}  <= quarterround(block_32_2, block_32_7, block_32_8 , block_32_13);
                    {block_32_3, block_32_4, block_32_9 , block_32_14}  <= quarterround(block_32_3, block_32_4, block_32_9 , block_32_14);
                    round_count <=  round_count + 1'b1;
                end
                qr_state = ~qr_state;
            end
            else if (round_count == 4'd10) begin
                block_32_0 <= block_32_0  + origin_block_32_0 ;
                block_32_1 <= block_32_1  + origin_block_32_1 ;
                block_32_2 <= block_32_2  + origin_block_32_2 ;
                block_32_3 <= block_32_3  + origin_block_32_3 ;
                block_32_4 <= block_32_4  + origin_block_32_4 ;
                block_32_5 <= block_32_5  + origin_block_32_5 ;
                block_32_6 <= block_32_6  + origin_block_32_6 ;
                block_32_7 <= block_32_7  + origin_block_32_7 ;
                block_32_8 <= block_32_8  + origin_block_32_8 ;
                block_32_9 <= block_32_9  + origin_block_32_9 ;
                block_32_10<= block_32_10 + origin_block_32_10;
                block_32_11<= block_32_11 + origin_block_32_11;
                block_32_12<= block_32_12 + origin_block_32_12;
                block_32_13<= block_32_13 + origin_block_32_13;
                block_32_14<= block_32_14 + origin_block_32_14;
                block_32_15<= block_32_15 + origin_block_32_15;
                round_count <=  round_count + 1'b1;
            end
        end
        else if (state == FINISH) begin
            round_count  <= 4'b0;
            qr_state     <= 1'b0;
            counter      <= counter + 1'b1;
        end
    end


    // FIFO
    always @(negedge aclk or negedge areset_n) begin
        if(~areset_n)
            origin_data_fifo_rd_en <=  1'b0;
        else if((state == QUARTERROUND) && round_count >= 4'd10 && origin_data_fifo_data_count >= 12'd16)
            origin_data_fifo_rd_en <=  1'b1;
        else if((state == SERIALIZE) && serialize_count <= 4'd15 && ~origin_data_fifo_empty)
            origin_data_fifo_rd_en <=  1'b1;
        else
            origin_data_fifo_rd_en <=  1'b0;
    end

    always @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            serialize_result_valid  <=  'b0;
            serialize_result        <=  'b0;
            serialize_count         <=  'b0;
        end
        else if(state == SERIALIZE) begin
            if (serialize_count < 5'd16 && ~origin_data_fifo_data_rd_rst_busy) begin
                serialize_result_valid  <=  1'b1;

                case (serialize_count)
                    5'd0 :  serialize_result        <=  origin_data_fifo_data ^ block_32_0 ;
                    5'd1 :  serialize_result        <=  origin_data_fifo_data ^ block_32_1 ;
                    5'd2 :  serialize_result        <=  origin_data_fifo_data ^ block_32_2 ;
                    5'd3 :  serialize_result        <=  origin_data_fifo_data ^ block_32_3 ;
                    5'd4 :  serialize_result        <=  origin_data_fifo_data ^ block_32_4 ;
                    5'd5 :  serialize_result        <=  origin_data_fifo_data ^ block_32_5 ;
                    5'd6 :  serialize_result        <=  origin_data_fifo_data ^ block_32_6 ;
                    5'd7 :  serialize_result        <=  origin_data_fifo_data ^ block_32_7 ;
                    5'd8 :  serialize_result        <=  origin_data_fifo_data ^ block_32_8 ;
                    5'd9 :  serialize_result        <=  origin_data_fifo_data ^ block_32_9 ;
                    5'd10:  serialize_result        <=  origin_data_fifo_data ^ block_32_10;
                    5'd11:  serialize_result        <=  origin_data_fifo_data ^ block_32_11;
                    5'd12:  serialize_result        <=  origin_data_fifo_data ^ block_32_12;
                    5'd13:  serialize_result        <=  origin_data_fifo_data ^ block_32_13;
                    5'd14:  serialize_result        <=  origin_data_fifo_data ^ block_32_14;
                    5'd15:  serialize_result        <=  origin_data_fifo_data ^ block_32_15;
                    default: serialize_result       <=  'b0;
                endcase
                
                serialize_count         <=  serialize_count + 1'b1;
            end
        end
        else if (state == FINISH)
            serialize_count         <=  'b0;
        else begin
            serialize_result_valid  <=  'b0;
            serialize_result        <=  'b0;
        end
    end

    always @(*) begin
        case (state)
            WAIT_INIT: begin
                next_state = init_data ? QUARTERROUND_PRE : WAIT_INIT;
            end
            QUARTERROUND_PRE: begin
                next_state = QUARTERROUND;
            end
            QUARTERROUND: begin
                next_state = (round_count >= 4'd10 && ~origin_data_fifo_empty) ? START_SERIALIZE_PRE : QUARTERROUND;
            end
            START_SERIALIZE_PRE: begin
                next_state = SERIALIZE;
            end
            SERIALIZE: begin
                next_state = (serialize_count == 5'd16 || origin_data_fifo_empty) ? FINISH : START_SERIALIZE_PRE;
            end
            FINISH: begin
                next_state = WAIT_INIT;
            end
            default: next_state = WAIT_INIT;
        endcase
    end

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n) state <= WAIT_INIT;
        else state <= next_state;
    end

    function automatic [32*4-1:0] quarterround(input [31:0] a, input [31:0] b, input [31:0] c, input [31:0] d);
        begin : qr
            reg [31:0] a0, a1;
            reg [31:0] b0, b1, b2, b3;
            reg [31:0] c0, c1;
            reg [31:0] d0, d1, d2, d3;

            a0           = a + b;
            d0           = d ^ a0;
            d1           = {d0[15:0], d0[31:16]};
            c0           = c + d1;
            b0           = b ^ c0;
            b1           = {b0[19:0], b0[31:20]};
            a1           = a0 + b1;
            d2           = d1 ^ a1;
            d3           = {d2[23:0], d2[31:24]};
            c1           = c0 + d3;
            b2           = b1 ^ c1;
            b3           = {b2[24:0], b2[31:25]};

            quarterround = {a1, b3, c1, d3};
        end
    endfunction

    reg result_data_fifo_rd_en_reg;

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n)
            result_data_fifo_rd_en  <=  1'b0;
        else if (o_axis_tready && ~result_data_fifo_empty)
            result_data_fifo_rd_en  <=  1'b1;
        else 
            result_data_fifo_rd_en  <=  1'b0;
    end

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n)
            result_data_fifo_rd_en_reg  <=  1'b0;
        else 
            result_data_fifo_rd_en_reg  <=  result_data_fifo_rd_en;
    end

    always @(posedge aclk or negedge areset_n) begin
        if (~areset_n) begin
            o_axis_tvalid  <=  1'b0;
            o_axis_tdata   <=  32'b0;
        end
        else if (result_data_fifo_rd_en & result_data_fifo_rd_en_reg) begin
            o_axis_tvalid  <=  1'b1;
            o_axis_tdata   <=  result_data_fifo_data;
        end
        else begin
            o_axis_tvalid  <=  1'b0;
            o_axis_tdata   <=  32'b0;
        end
    end 
    
result_data_fifo u_result_data_fifo (
  .clk(aclk),                  // input wire clk
  .rst(~areset_n),                  // input wire rst
  .din(serialize_result),                  // input wire [31 : 0] din
  .wr_en(serialize_result_valid),  // input wire wr_en
  
  .rd_en(result_data_fifo_rd_en),              // input wire rd_en
  .dout(result_data_fifo_data),                // output wire [31 : 0] dout
  .full(),                // output wire full
  .empty(result_data_fifo_empty),              // output wire empty
  .data_count(result_data_fifo_data_count),    // output wire [8 : 0] data_count
  .wr_rst_busy(result_data_fifo_wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(result_data_fifo_rd_rst_busy)  // output wire rd_rst_busy
);

origin_data_fifo u_origin_data_fifo (
  .clk(aclk),                // input wire clk
  .rst(~areset_n),              // input wire srst
  .din(i_axis_tdata),                // input wire [31 : 0] din
  .wr_en(i_axis_tready & i_axis_tvalid & ~origin_data_fifo_full),            // input wire wr_en
  .rd_en(origin_data_fifo_rd_en),            // input wire rd_en
  .dout(origin_data_fifo_data),              // output wire [31 : 0] dout
  .full(origin_data_fifo_full),              // output wire full
  .empty(origin_data_fifo_empty),            // output wire empty
  .data_count(origin_data_fifo_data_count),  // output wire [8 : 0] data_count
  .wr_rst_busy(origin_data_fifo_data_wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(origin_data_fifo_data_rd_rst_busy)  // output wire rd_rst_busy
);

endmodule
