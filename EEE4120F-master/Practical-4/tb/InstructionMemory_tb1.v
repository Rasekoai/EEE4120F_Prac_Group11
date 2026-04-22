`timescale 1ns / 1ps
`include "../src/Parameter.v"

module InstructionMemory_tb;
    reg  [15:0] pc;
    wire [15:0] instruction;

    InstructionMemory uut (
        .pc          (pc),
        .instruction (instruction)
    );

    integer i;
    initial begin
        // Walk through all 16 word addresses (PC = 0,2,4,...,30)
        for (i = 0; i < 16; i = i + 1) begin
            pc = i * 2;
            #5;
            $display("PC=%0d (rom_addr=%0d) => instruction=%b", pc, pc[4:1], instruction);
        end

        // Verify pc[0] (byte select) is ignored — same instruction for PC and PC+1
        pc = 16'd4; #5;
        $display("PC=4 instr=%b", instruction);
        pc = 16'd5; #5;
        $display("PC=5 instr=%b (should match PC=4)", instruction);

        $display("InstructionMemory testbench complete.");
        $finish;
    end
endmodule