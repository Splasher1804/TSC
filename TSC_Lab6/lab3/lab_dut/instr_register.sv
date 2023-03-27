/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/
//semnalele trebuie sa aibe interfata.semnal ca la structura
  timeunit 1ns/1ns;
module instr_register(tb_ifc.DUT tbifc);
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
// (input  logic          tbifc.clk,
//  input  logic          load_en,
//  input  logic          tbifc.reset_n,
//  input  tbifc.operand_t      tbifc.operand_a,
//  input  tbifc.operand_t      tbifc.operand_b,
//  input  opcode_t       opcode,
//  input  address_t      write_pointer,
//  input  address_t      read_pointer,
//  output instruction_t  instruction_word
// );


  instruction_t  iw_reg [0:31];  // an array of instruction_word structures
  result_t result_rez;

  // write to the register
  always@(posedge tbifc.clk, negedge tbifc.reset_n)   // write into register
    if (!tbifc.reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (tbifc.load_en) begin
    case(tbifc.opcode)
      ZERO : result_rez = 0;
      PASSA: result_rez = tbifc.operand_a;
      PASSB: result_rez = tbifc.operand_b;
      ADD  : result_rez = tbifc.operand_a + tbifc.operand_b;
      SUB  : result_rez = tbifc.operand_a - tbifc.operand_b;
      MULT : result_rez = tbifc.operand_a * tbifc.operand_b;
      DIV  : result_rez = tbifc.operand_a / tbifc.operand_b;
      MOD  : result_rez = tbifc.operand_a % tbifc.operand_b;
    endcase

      iw_reg[tbifc.write_pointer] = '{tbifc.opcode,tbifc.operand_a,tbifc.operand_b, result_rez};
    end

  // read from the register
  assign tbifc.instruction_word = iw_reg[tbifc.read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force tbifc.operand_b = tbifc.operand_a; // cause wrong value to be loaded into tbifc.operand_b
end
`endif

endmodule: instr_register
