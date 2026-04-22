`timescale 1ns / 1ps
`include "../src/Parameter.v"

module ControlUnit_tb;
    reg  [3:0] opcode;
    wire [1:0] alu_op;
    wire       jump, beq, bne, mem_read, mem_write;
    wire       alu_src, reg_dst, mem_to_reg, reg_write;

    ControlUnit uut (
        .opcode     (opcode),
        .alu_op     (alu_op),
        .jump       (jump),
        .beq        (beq),
        .bne        (bne),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .reg_dst    (reg_dst),
        .mem_to_reg (mem_to_reg),
        .reg_write  (reg_write)
    );

    task check;
        input exp_reg_dst, exp_alu_src, exp_mem_to_reg, exp_reg_write;
        input exp_mem_read, exp_mem_write, exp_beq, exp_bne;
        input [1:0] exp_alu_op;
        input exp_jump;
        input [31:0] test_num;
        begin
            #1;
            if (reg_dst    !== exp_reg_dst    ||
                alu_src    !== exp_alu_src    ||
                mem_to_reg !== exp_mem_to_reg ||
                reg_write  !== exp_reg_write  ||
                mem_read   !== exp_mem_read   ||
                mem_write  !== exp_mem_write  ||
                beq        !== exp_beq        ||
                bne        !== exp_bne        ||
                alu_op     !== exp_alu_op     ||
                jump       !== exp_jump)
                $display("FAIL test %0d opcode=%b: got RegDst=%b ALUSrc=%b M2R=%b RW=%b MR=%b MW=%b beq=%b bne=%b aluop=%b jmp=%b",
                         test_num, opcode, reg_dst, alu_src, mem_to_reg, reg_write,
                         mem_read, mem_write, beq, bne, alu_op, jump);
            else
                $display("PASS test %0d opcode=%b", test_num, opcode);
        end
    endtask

    initial begin
        // LD
        opcode = 4'b0000;
        check(0,1,1,1, 1,0,0,0, 2'b10,0, 1);

        // ST
        opcode = 4'b0001;
        check(0,1,0,0, 0,1,0,0, 2'b10,0, 2);

        // R-type: ADD SUB INV SHL SHR AND OR SLT
        opcode = 4'b0010; check(1,0,0,1, 0,0,0,0, 2'b00,0, 3);
        opcode = 4'b0011; check(1,0,0,1, 0,0,0,0, 2'b00,0, 4);
        opcode = 4'b0100; check(1,0,0,1, 0,0,0,0, 2'b00,0, 5);
        opcode = 4'b0101; check(1,0,0,1, 0,0,0,0, 2'b00,0, 6);
        opcode = 4'b0110; check(1,0,0,1, 0,0,0,0, 2'b00,0, 7);
        opcode = 4'b0111; check(1,0,0,1, 0,0,0,0, 2'b00,0, 8);
        opcode = 4'b1000; check(1,0,0,1, 0,0,0,0, 2'b00,0, 9);
        opcode = 4'b1001; check(1,0,0,1, 0,0,0,0, 2'b00,0, 10);

        // Reserved 1010 — all zeros
        opcode = 4'b1010;
        check(0,0,0,0, 0,0,0,0, 2'b00,0, 11);

        // BEQ
        opcode = 4'b1011;
        check(0,0,0,0, 0,0,1,0, 2'b01,0, 12);

        // BNE
        opcode = 4'b1100;
        check(0,0,0,0, 0,0,0,1, 2'b01,0, 13);

        // JMP
        opcode = 4'b1101;
        check(0,0,0,0, 0,0,0,0, 2'b00,1, 14);

        $display("ControlUnit testbench complete.");
        $finish;
    end
endmodule