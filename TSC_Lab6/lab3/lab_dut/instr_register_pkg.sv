/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] {
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;

  typedef logic signed [31:0] operand_t;
  
  typedef logic [4:0] address_t;

  typedef logic [63:0] result_t;
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    result_t  rez;
    //rezultat numarul de biti penntru a si b 5+5 biti = 6 biti 5*5 biti =10 biti, max si min pentru a si b, unsigned si signed PASS a primeste valoarea lui a. System verilog case.
    //salvam rezultatul opcode, operand a, operand b si rezultat
  } instruction_t;

endpackage: instr_register_pkg


