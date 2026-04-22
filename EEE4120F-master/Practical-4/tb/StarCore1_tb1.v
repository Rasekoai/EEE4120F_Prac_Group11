`timescale 1ns / 1ps
`include "../src/Parameter.v"

module StarCore1_tb;
    reg clk;

    StarCore1 uut (.clk(clk));

    always #5 clk = ~clk;

    // Expose internals for monitoring
    wire [15:0] pc          = uut.DU.pc_current;
    wire [15:0] instr       = uut.DU.instr;
    wire [3:0]  opcode      = uut.DU.opcode;
    wire [15:0] alu_result  = uut.DU.alu_result;
    wire        reg_write   = uut.CU.reg_write;
    wire [2:0]  reg_wdest   = uut.DU.reg_write_dest;
    wire [15:0] reg_wdata   = uut.DU.reg_write_data;
    wire        mem_write   = uut.CU.mem_write;
    wire        mem_read    = uut.CU.mem_read;
    wire [15:0] mem_addr    = uut.DU.alu_result;
    wire [15:0] mem_rdata   = uut.DU.mem_read_data;

    integer cycle;

    initial begin
        $dumpfile("./waves/StarCore1_tb.vcd");
        $dumpvars(0, StarCore1_tb);

        clk   = 0;
        cycle = 0;

        $display("=============================================================");
        $display(" StarCore-1 Integration Testbench");
        $display("=============================================================");
        $display("%6s | %6s | %16s | %4s | %6s | %6s | Flags",
                 "Cycle", "PC", "Instr", "OP", "ALURes", "WBData");
        $display("-------------------------------------------------------------");
    end

    // Print one line per rising edge
    always @(posedge clk) begin
        #1; // Let combinational signals settle
        $display("%6d | %6h | %16b | %4b | %6h | %6h | RW=%b WD=%0d MW=%b MR=%b Maddr=%h Mrdata=%h",
                 cycle, pc, instr, opcode, alu_result, reg_wdata,
                 reg_write, reg_wdest, mem_write, mem_read, mem_addr, mem_rdata);
        cycle = cycle + 1;
    end

    initial begin
        `SIM_TIME;
        $display("=============================================================");
        $display(" Simulation complete after %0d cycles.", cycle);
        $display("=============================================================");
        $finish;
    end
endmodule