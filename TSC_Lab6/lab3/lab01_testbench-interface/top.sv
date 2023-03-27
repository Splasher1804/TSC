/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/
//Trebuie sa instantiem o instanta pentru interfata. Nume_interfata.semnal. Trebuie sa folosim modport si sa spunem care e output si ce este input.
module top;
  timeunit 1ns/1ns;//directiva de compilator care seteaza timpul de simulare, rezolutia si timpul

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // clock variables
  logic clk;
  logic test_clk;
  // interconnecting signals
  logic reset_n;
//denumire interfetei si denumirea de instanta
  
  //logic           load_en; 
  // opcode_t       opcode;
  // operand_t      operand_a, operand_b;
  // //result_t       result_rez;
  // address_t      write_pointer, read_pointer;
  // instruction_t  instruction_word;

  tb_ifc tbifc(
    .clk(clk),
    .test_clk(test_clk)
  );
 
  instr_register_test test(
    .tbifc(tbifc)
  );

  instr_register dut(
    .tbifc(tbifc)
  );
  

  // instantiate testbench and connect ports
  // instr_register_test test ( //instantierea modul +nume instanta
  //   .clk(test_clk),
  //   .load_en(load_en),
  //   .reset_n(reset_n),
  //   .operand_a(operand_a),
  //   .operand_b(operand_b),
  //   //.result_rez(result_rez),
  //   .opcode(opcode),
  //   .write_pointer(write_pointer),
  //   .read_pointer(read_pointer),
  //   .instruction_word(instruction_word)
  //  );

  // // instantiate design and connect ports
  // instr_register dut (
  //   .clk(clk),
  //   .load_en(load_en),
  //   .reset_n(reset_n),
  //   .operand_a(operand_a),
  //   .operand_b(operand_b),
  //   //.result_rez(result_rez),
  //   .opcode(opcode),
  //   .write_pointer(write_pointer),
  //   .read_pointer(read_pointer),
  //   .instruction_word(instruction_word)
  //  );

  // clock oscillators
  initial begin
    clk <= 0;
    forever #5  clk = ~clk;
  end

  initial begin
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
