module tb_quarterround;

    // chacha20_quarterround Parameters
    parameter PERIOD = 10;
    reg        clk = 0;

    reg        qr_state = 0;
    reg [31:0] block_32     [15:0];

    initial begin
        $readmemh("data.txt", block_32);
        for (integer n = 0; n <= 7; n = n + 1) $display("%h", block_32[n]);
    end

    initial begin
        forever #(PERIOD / 2) clk = ~clk;
    end

    initial begin
        $monitor($time);
        $dumpfile("qr.vcd");
        $dumpvars(0, tb_quarterround);
        $dumpon;
        #300 $dumpoff;
        $finish;
        
       
    end

    generate
        genvar idx;
        for (idx = 0; idx < 16; idx = idx + 1) begin : register
            wire [31:0] tmp;
            assign tmp = block_32[idx];
        end
    endgenerate

    reg [4:0]   count   =   0;

    always @(posedge clk) begin
        if (count <= 'd9) begin
            if (~qr_state) begin
                {block_32[0], block_32[4], block_32[8], block_32[12]}  <= quarterround(block_32[0], block_32[4], block_32[8], block_32[12]);
                {block_32[1], block_32[5], block_32[9], block_32[13]}  <= quarterround(block_32[1], block_32[5], block_32[9], block_32[13]);
                {block_32[2], block_32[6], block_32[10], block_32[14]} <= quarterround(block_32[2], block_32[6], block_32[10], block_32[14]);
                {block_32[3], block_32[7], block_32[11], block_32[15]} <= quarterround(block_32[3], block_32[7], block_32[11], block_32[15]);
            end
            else begin
                {block_32[0], block_32[5], block_32[10], block_32[15]} <= quarterround(block_32[0], block_32[5], block_32[10], block_32[15]);
                {block_32[1], block_32[6], block_32[11], block_32[12]} <= quarterround(block_32[1], block_32[6], block_32[11], block_32[12]);
                {block_32[2], block_32[7], block_32[8], block_32[13]}  <= quarterround(block_32[2], block_32[7], block_32[8], block_32[13]);
                {block_32[3], block_32[4], block_32[9], block_32[14]}  <= quarterround(block_32[3], block_32[4], block_32[9], block_32[14]);
                count <= count + 1;
            end
            qr_state = ~qr_state;
        end
        $display("%d =============",count);
            for (integer n = 0; n <= 3; n = n + 1) 
                    $display("%h %h %h %h", block_32[n * 4], block_32[n * 4 + 1], block_32[n * 4 + 2],block_32[n * 4 + 3]);
                
                    $display("=============");
        
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

endmodule
