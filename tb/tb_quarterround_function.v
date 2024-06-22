module tb_quarterround_function;

    // chacha20_quarterround Parameters
    parameter PERIOD = 10;
    reg        clk = 0;

    //https://tools.ietf.org/html/rfc7539#section-2.1.1
    // chacha20_quarterround Inputs
    reg [31:0] a = 32'h11111111;
    reg [31:0] b = 32'h01020304;
    reg [31:0] c = 32'h9b8d6f43;
    reg [31:0] d = 32'h01234567;

    // chacha20_quarterround Outputs
    //{ 0xea2a92f4, 0xcb1cf8ce, 0x4581472e, 0x5881c4bb }
    reg [31:0] a_out = 0;
    reg [31:0] b_out = 0;
    reg [31:0] c_out = 0;
    reg [31:0] d_out = 0;


    initial begin
        forever #(PERIOD / 2) clk = ~clk;
    end

    initial begin
        $monitor($time);
        $dumpfile("qr_function.vcd");
        $dumpvars(0, tb_quarterround_function);
        $dumpon;
        #40 $dumpoff;
        $finish;
    end

    always @(posedge clk) begin
        {d_out, c_out, b_out, a_out} <= quarterround(a, b, c, d);
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

            quarterround = {d3, c1, b3, a1};
        end
    endfunction

endmodule
