`timescale 1ns / 1ps
`include "../src/Parameter.v"

module DataMemory_tb;
    reg        clk, mem_write_en, mem_read;
    reg  [15:0] mem_access_addr, mem_write_data;
    wire [15:0] mem_read_data;

    DataMemory uut (
        .clk             (clk),
        .mem_access_addr (mem_access_addr),
        .mem_write_data  (mem_write_data),
        .mem_write_en    (mem_write_en),
        .mem_read        (mem_read),
        .mem_read_data   (mem_read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; mem_write_en = 0; mem_read = 0;
        mem_access_addr = 0; mem_write_data = 0;

        // Read initialized values from file (mem_read gated)
        #2;
        mem_read = 1; mem_access_addr = 16'd0;
        #1;
        $display("Init read addr=0: %h", mem_read_data);
        mem_access_addr = 16'd1;
        #1;
        $display("Init read addr=1: %h", mem_read_data);

        // Gated read: mem_read=0 should output 0
        mem_read = 0; mem_access_addr = 16'd0;
        #1;
        if (mem_read_data !== 16'd0)
            $display("FAIL gated read: expected 0, got %h", mem_read_data);
        else
            $display("PASS gated read outputs 0");

        // Synchronous write then read back
        mem_write_en = 1; mem_access_addr = 16'd2; mem_write_data = 16'hBEEF;
        @(posedge clk); #1;
        mem_write_en = 0; mem_read = 1;
        #1;
        if (mem_read_data !== 16'hBEEF)
            $display("FAIL write-read: expected BEEF, got %h", mem_read_data);
        else
            $display("PASS write-read addr=2: BEEF");

        // Write addr=5, verify addr=2 unchanged
        mem_write_en = 1; mem_access_addr = 16'd5; mem_write_data = 16'h1234;
        @(posedge clk); #1;
        mem_write_en = 0;
        mem_access_addr = 16'd2; #1;
        if (mem_read_data !== 16'hBEEF)
            $display("FAIL independence: addr=2 changed");
        else
            $display("PASS independence: addr=2 still BEEF");
        mem_access_addr = 16'd5; #1;
        if (mem_read_data !== 16'h1234)
            $display("FAIL addr=5: expected 1234, got %h", mem_read_data);
        else
            $display("PASS addr=5=1234");

        $display("DataMemory testbench complete.");
        $finish;
    end
endmodule