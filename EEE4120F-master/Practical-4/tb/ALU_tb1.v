`timescale 1ns / 1ps
`include "../src/Parameter.v"

module ALU_tb;
    reg  [15:0] a, b;
    reg  [ 2:0] alu_control;
    wire [15:0] result;
    wire        zero;

    ALU uut (
        .a           (a),
        .b           (b),
        .alu_control (alu_control),
        .result      (result),
        .zero        (zero)
    );

    task check;
        input [15:0] expected;
        input        exp_zero;
        input [63:0] test_num;
        begin
            #1;
            if (result !== expected || zero !== exp_zero)
                $display("FAIL test %0d: a=%h b=%h ctrl=%b => result=%h (exp %h) zero=%b (exp %b)",
                         test_num, a, b, alu_control, result, expected, zero, exp_zero);
            else
                $display("PASS test %0d: result=%h zero=%b", test_num, result, zero);
        end
    endtask

    initial begin
        // ADD
        alu_control = 3'b000; a = 16'h0003; b = 16'h0004; check(16'h0007, 0, 1);
        alu_control = 3'b000; a = 16'hFFFF; b = 16'h0001; check(16'h0000, 1, 2);

        // SUB
        alu_control = 3'b001; a = 16'h000A; b = 16'h0003; check(16'h0007, 0, 3);
        alu_control = 3'b001; a = 16'h0005; b = 16'h0005; check(16'h0000, 1, 4);

        // INV
        alu_control = 3'b010; a = 16'hAAAA; b = 16'h0000; check(16'h5555, 0, 5);
        alu_control = 3'b010; a = 16'hFFFF; b = 16'h0000; check(16'h0000, 1, 6);

        // SHL
        alu_control = 3'b011; a = 16'h0001; b = 16'h0003; check(16'h0008, 0, 7);
        alu_control = 3'b011; a = 16'h0001; b = 16'h000F; check(16'h8000, 0, 8);

        // SHR
        alu_control = 3'b100; a = 16'h0008; b = 16'h0003; check(16'h0001, 0, 9);
        alu_control = 3'b100; a = 16'h0001; b = 16'h0001; check(16'h0000, 1, 10);

        // AND
        alu_control = 3'b101; a = 16'hFF00; b = 16'h0FF0; check(16'h0F00, 0, 11);
        alu_control = 3'b101; a = 16'hAAAA; b = 16'h5555; check(16'h0000, 1, 12);

        // OR
        alu_control = 3'b110; a = 16'hF000; b = 16'h000F; check(16'hF00F, 0, 13);
        alu_control = 3'b110; a = 16'h0000; b = 16'h0000; check(16'h0000, 1, 14);

        // SLT
        alu_control = 3'b111; a = 16'h0003; b = 16'h0005; check(16'h0001, 0, 15);
        alu_control = 3'b111; a = 16'h0005; b = 16'h0003; check(16'h0000, 1, 16);
        alu_control = 3'b111; a = 16'h0005; b = 16'h0005; check(16'h0000, 1, 17);

        $display("ALU testbench complete.");
        $finish;
    end
endmodule