`timescale 1ns / 1ps

module tb_chacha20;

    // chacha20 Parameters
    parameter PERIOD = 10;
    parameter AXI_IDWIDTH = 4;

    // chacha20 Inputs
    reg                    aclk = 0;
    reg                    areset_n = 0;
    reg                    axi_input_tvalid = 0;
    reg                    axi_input_tlast = 0;
    reg  [           31:0] axi_input_tdata = 0;
    reg                    s_axi_awvalid = 0;
    reg  [           63:0] s_axi_awaddr = 0;
    reg  [            7:0] s_axi_awlen = 0;
    reg  [AXI_IDWIDTH-1:0] s_axi_awid = 0;
    reg                    s_axi_wvalid = 0;
    reg                    s_axi_wlast = 0;
    reg  [           64:0] s_axi_wdata = 0;
    reg                    s_axi_bready = 1;
    reg                    axi_output_tready = 1;
    reg                    init_data_finish = 0;

    // chacha20 Outputs
    wire                   axi_input_tready;
    wire                   s_axi_awready;
    wire                   s_axi_wready;
    wire                   s_axi_bvalid;
    wire [AXI_IDWIDTH-1:0] s_axi_bid;
    wire [            1:0] s_axi_bresp;
    wire                   axi_output_tvalid;
    wire                   axi_output_tlast;
    wire [           31:0] axi_output_tdata;
    wire                   outdate_key;
    reg  [           31:0] data                  [28:0];

    initial begin
        forever #(PERIOD / 2) aclk = ~aclk;
    end

    initial begin
        $readmemh("./../../../../../tb/data.txt", data);
        #(PERIOD * 2) areset_n = 1;
    end

    reg [3:0] axi_config_count = 0;
    reg       axi_write_data_flag = 0;


    always @(posedge aclk or negedge areset_n) begin
        if (!areset_n) begin
            axi_config_count <= 'b0;
            s_axi_awvalid    <= 'b0;
            s_axi_awaddr     <= 'b0;
            s_axi_awlen      <= 'b0;
            s_axi_awid       <= 'b0;

            s_axi_wvalid     <= 'b0;
            s_axi_wlast      <= 'b0;
            s_axi_wdata      <= 'b0;

            s_axi_bready     <= 'b1;
        end
        else begin
            if (s_axi_bvalid) axi_config_count <= axi_config_count + 1'b1;
            case (axi_config_count)
                4'd0: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000000;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h07060504, 32'h03020100};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd1: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000010;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h0f0e0d0c, 32'h0b0a0908};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd2: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000020;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h17161514, 32'h13121110};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd3: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000030;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h1f1e1d1c, 32'h1b1a1918};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd4: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000040;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h00000000, 32'h00000001};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd5: begin
                    if (~axi_write_data_flag) begin
                        s_axi_awvalid <= 1'b1;
                        s_axi_awaddr  <= 64'h00000050;
                        s_axi_awlen   <= 1'b0;
                        s_axi_awid    <= 1'b0;

                        s_axi_wvalid  <= 'b0;
                        s_axi_wlast   <= 'b0;
                        s_axi_wdata   <= 'b0;
                    end
                    else begin
                        s_axi_awvalid <= 'b0;
                        s_axi_awaddr  <= 'b0;
                        s_axi_awlen   <= 'b0;
                        s_axi_awid    <= 'b0;

                        s_axi_wvalid  <= 1'b1;
                        s_axi_wlast   <= 1'b1;
                        s_axi_wdata   <= {32'h00000000, 32'h4a000000};
                    end
                    axi_write_data_flag <= ~axi_write_data_flag;
                end
                4'd6: begin
                    s_axi_awvalid    <= 'b0;
                    s_axi_awaddr     <= 'b0;
                    s_axi_awlen      <= 'b0;
                    s_axi_awid       <= 'b0;
                    s_axi_wvalid     <= 'b0;
                    s_axi_wlast      <= 'b0;
                    s_axi_wdata      <= 'b0;
                    s_axi_bready     <= 'b1;
                    init_data_finish <= 'b1;
                end
                default: begin
                    s_axi_awvalid <= 'b0;
                    s_axi_awaddr  <= 'b0;
                    s_axi_awlen   <= 'b0;
                    s_axi_awid    <= 'b0;
                    s_axi_wvalid  <= 'b0;
                    s_axi_wlast   <= 'b0;
                    s_axi_wdata   <= 'b0;
                    s_axi_bready  <= 'b1;
                end
            endcase
        end
    end

    reg [31:0]  write_data_count = 0;

    always @(posedge aclk or negedge areset_n) begin
        if (write_data_count <= 28 && axi_input_tready) begin
            axi_input_tvalid    <=  1'b1;
            axi_input_tdata     <=  data[write_data_count];
            if (write_data_count == 31) begin
                axi_input_tlast <=  1'b1;
            end
            write_data_count    <=  write_data_count + 1;
        end
        else
            axi_input_tvalid    <=  1'b0;
    end

chacha20 #(
    .AXI_IDWIDTH ( AXI_IDWIDTH ))
 u_chacha20 (
    .aclk                    ( aclk                                    ),
    .areset_n                ( areset_n                                ),

    .i_axis_tready           ( axi_input_tready                     ),
    .i_axis_tvalid           ( axi_input_tvalid                     ),
    .i_axis_tdata            ( axi_input_tdata    [           31:0] ),

    .s_axi_awvalid           ( s_axi_awvalid                           ),
    .s_axi_awaddr            ( s_axi_awaddr          [           63:0] ),
    .s_axi_awlen             ( s_axi_awlen           [            7:0] ),
    .s_axi_awid              ( s_axi_awid            [AXI_IDWIDTH-1:0] ),
    .s_axi_wvalid            ( s_axi_wvalid                            ),
    .s_axi_wlast             ( s_axi_wlast                             ),
    .s_axi_wdata             ( s_axi_wdata           [           64:0] ),
    .s_axi_bready            ( s_axi_bready                            ),
    
    .init_data_finish        ( init_data_finish                        ),
    
    .s_axi_awready           ( s_axi_awready                           ),
    .s_axi_wready            ( s_axi_wready                            ),
    .s_axi_bvalid            ( s_axi_bvalid                            ),
    .s_axi_bid               ( s_axi_bid             [AXI_IDWIDTH-1:0] ),
    .s_axi_bresp             ( s_axi_bresp           [            1:0] ),

    
    .o_axis_tvalid           ( axi_output_tvalid                    ),
    .o_axis_tdata            ( axi_output_tdata   [           31:0] ),
    .o_axis_tready           ( axi_output_tready                    ),

    .outdate_key             ( outdate_key                             )
);

    initial begin

        $finish;
    end

endmodule
