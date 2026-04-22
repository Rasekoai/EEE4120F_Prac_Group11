`timescale 1ns / 1ps
`include "../src/Parameter.v"

module ALU_Control_tb;
    reg  [1:0] ALUOp;
    reg  [3:0] Opcode;
    wire [2:0] ALU_Cnt;

    ALU_Control uut (
        .ALUOp   (ALUOp),
        .Opcode  (Opcode),
        .ALU_Cnt (ALU_Cnt)
    );

    task check;
        input [2:0] expected;
        input [31:0] test_num;
        begin
            #1;
            if (ALU_Cnt !== expected)
                $display("FAIL test %0d: ALUOp=%b Opcode=%b => ALU_Cnt=%b (exp %b)",
                         test_num, ALUOp, Opcode, ALU_Cnt, expected);
            else
                $display("PASS test %0d: ALUOp=%b Opcode=%b => ALU_Cnt=%b",
                         test_num, ALUOp, Opcode, ALU_Cnt);
        end
    endtask

    initial begin
        // ALUOp=10 (I-type): always ADD
        ALUOp = 2'b10; Opcode = 4'b0000; check(3'b000, 1);
        ALUOp = 2'b10; Opcode = 4'b0001; check(3'b000, 2);
        ALUOp = 2'b10; Opcode = 4'b1111; check(3'b000, 3);

        // ALUOp=01 (Branch): always SUB
        ALUOp = 2'b01; Opcode = 4'b1011; check(3'b001, 4);
        ALUOp = 2'b01; Opcode = 4'b1100; check(3'b001, 5);
        ALUOp = 2'b01; Opcode = 4'b0000; check(3'b001, 6);

        // ALUOp=00 (R-type): decode from opcode
        ALUOp = 2'b00; Opcode = 4'b0010; check(3'b000, 7);  // ADD
        ALUOp = 2'b00; Opcode = 4'b0011; check(3'b001, 8);  // SUB
        ALUOp = 2'b00; Opcode = 4'b0100; check(3'b010, 9);  // INV
        ALUOp = 2'b00; Opcode = 4'b0101; check(3'b011, 10); // SHL
        ALUOp = 2'b00; Opcode = 4'b0110; check(3'b100, 11); // SHR
        ALUOp = 2'b00; Opcode = 4'b0111; check(3'b101, 12); // AND
        ALUOp = 2'b00; Opcode = 4'b1000; check(3'b110, 13); // OR
        ALUOp = 2'b00; Opcode = 4'b1001; check(3'b111, 14); // SLT

        // Default
        ALUOp = 2'b00; Opcode = 4'b1111; check(3'b000, 15);

        $display("ALU_Control testbench complete.");
        $finish;
    end
endmodule