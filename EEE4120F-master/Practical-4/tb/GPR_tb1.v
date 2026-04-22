`timescale 1ns / 1ps
`include "../src/Parameter.v"

module GPR_tb;
    reg        clk, reg_write_en;
    reg  [2:0] reg_write_dest, reg_read_addr_1, reg_read_addr_2;
    reg  [15:0] reg_write_data;
    wire [15:0] reg_read_data_1, reg_read_data_2;

    GPR uut (
        .clk             (clk),
        .reg_write_en    (reg_write_en),
        .reg_write_dest  (reg_write_dest),
        .reg_write_data  (reg_write_data),
        .reg_read_addr_1 (reg_read_addr_1),
        .reg_read_data_1 (reg_read_data_1),
        .reg_read_addr_2 (reg_read_addr_2),
        .reg_read_data_2 (reg_read_data_2)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reg_write_en = 0;
        reg_write_dest = 0; reg_write_data = 0;
        reg_read_addr_1 = 0; reg_read_addr_2 = 0;

        // Read-before-write: all regs should be 0 after init
        #2;
        reg_read_addr_1 = 3'd1; reg_read_addr_2 = 3'd2;
        #1;
        if (reg_read_data_1 !== 16'd0 || reg_read_data_2 !== 16'd0)
            $display("FAIL read-before-write: expected 0s, got %h %h",
                     reg_read_data_1, reg_read_data_2);
        else
            $display("PASS read-before-write");

        // Write-then-read R3 = 0xABCD
        reg_write_en = 1; reg_write_dest = 3'd3; reg_write_data = 16'hABCD;
        @(posedge clk); #1;
        reg_write_en = 0;
        reg_read_addr_1 = 3'd3;
        #1;
        if (reg_read_data_1 !== 16'hABCD)
            $display("FAIL write-then-read: expected ABCD, got %h", reg_read_data_1);
        else
            $display("PASS write-then-read R3=ABCD");

        // Register independence: write R5, check R3 unchanged
        reg_write_en = 1; reg_write_dest = 3'd5; reg_write_data = 16'h1234;
        @(posedge clk); #1;
        reg_write_en = 0;
        reg_read_addr_1 = 3'd3; reg_read_addr_2 = 3'd5;
        #1;
        if (reg_read_data_1 !== 16'hABCD)
            $display("FAIL independence: R3 changed to %h", reg_read_data_1);
        else
            $display("PASS independence: R3 still ABCD");
        if (reg_read_data_2 !== 16'h1234)
            $display("FAIL independence: R5=%h, expected 1234", reg_read_data_2);
        else
            $display("PASS independence: R5=1234");

        // Write R7 = 0xFFFF
        reg_write_en = 1; reg_write_dest = 3'd7; reg_write_data = 16'hFFFF;
        @(posedge clk); #1;
        reg_write_en = 0;
        reg_read_addr_1 = 3'd7;
        #1;
        if (reg_read_data_1 !== 16'hFFFF)
            $display("FAIL R7: expected FFFF, got %h", reg_read_data_1);
        else
            $display("PASS R7=FFFF");

        $display("GPR testbench complete.");
        $finish;
    end
endmodule