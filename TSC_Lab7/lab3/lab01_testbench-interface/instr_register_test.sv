/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
//Trebuie sa instantiem o instanta pentru interfata. Nume_interfata.semnal. 
//Trebuie sa folosim modport si sa spunem care e output si ce este input.
timeunit 1ns/1ns;
module instr_register_test(tb_ifc.TEST tbifc);

  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  // (input  logic          tbifc.test_clk,
  //  output logic          load_en,
  //  output logic          tbifc.reset_n,
  //  output operand_t      operand_a,
  //  output operand_t      operand_b,
  //  //output result_t       result_rez,
  //  output opcode_t       opcode,
  //  output address_t      write_pointer,
  //  output address_t      read_pointer,
  //  input  instruction_t  instruction_word
  // );
  
  
  parameter type_of_transaction = 2;
  result_t result_rez;
   result_t expected_result_rez;
  //err_checker err_count;
  int err_count;
  parameter no_of_transactions  = 20;
  int seed = 77777; //este procedura prin care se initializeaza generarea numerelor random.
  
 initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    tbifc.write_pointer  = 5'h00;         // initialize write pointer
    tbifc.read_pointer   = 5'h1F;         // initialize read pointer
    tbifc.load_en        = 1'b0;          // initialize load control line
    tbifc.reset_n       <= 1'b0;          // assert tbifc.reset_n (active low)
    repeat (2) @(posedge tbifc.test_clk) ;     // hold in reset for 2 clock cycles
    tbifc.reset_n        = 1'b1;          // deassert tbifc.reset_n (active low)

    $display("\nWriting values to register stack...");
   // @(posedge tbifc.test_clk) load_en = 1'b1;  // enable writing to register
    repeat (no_of_transactions) begin
      @(posedge tbifc.test_clk) begin
        randomize_transaction;
        tbifc.load_en <= 1'b1;
      end
      @(negedge tbifc.test_clk) print_transaction;
    end
    @(posedge tbifc.test_clk) tbifc.load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<no_of_transactions; i++) begin


      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      
    //    if(type_of_transaction==0 || type_of_transaction==2) begin
    //   @(posedge tbifc.test_clk) tbifc.read_pointer = i;
    //   else @(posedge tbifc.test_clk) tbifc.read_pointer = $unsigned($random)%32;
    // end
     case(type_of_transaction)
      0 :  @(posedge tbifc.test_clk) tbifc.read_pointer = i;
      1 :  @(posedge tbifc.test_clk) tbifc.read_pointer = $unsigned($random)%32;
      2 :  @(posedge tbifc.test_clk) tbifc.read_pointer = i; 
      3 :  @(posedge tbifc.test_clk) tbifc.read_pointer = $unsigned($random)%32;
     endcase
     // @(posedge tbifc.test_clk) read_pointer = i;
    //@(posedge tbifc.test_clk) tbifc.read_pointer = $unsigned($random)%32;
      //@(negedge tbifc.test_clk) print_results;

      @(negedge tbifc.test_clk) check_results;
        if (expected_result_rez != result_rez) begin
          err_count=err_count + 1; 
      end

    
     
    end

    @(posedge tbifc.test_clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    if (err_count == 0) begin
          $display("Succes"); 
        else
          $display("Failed");
        
      end
    
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    tbifc.operand_a     <= $random()%16;                 // between -15 and 15
    tbifc.operand_b     <= $unsigned($random)%16;            // between 0 and 15                    
    tbifc.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    //tbifc.write_pointer <= temp++;
    //tbifc.write_pointer <=  $unsigned($random)%32;
    case(type_of_transaction)
      0 : tbifc.write_pointer <= temp++;
      1 : tbifc.write_pointer <= temp++;
      2 : tbifc.write_pointer <= $unsigned($random)%32;
      3 : tbifc.write_pointer <= $unsigned($random)%32;
     endcase
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", tbifc.write_pointer);
    $display("  opcode = %0d (%s)",tbifc.opcode, tbifc.opcode.name);
    $display("  operand_a = %0d",  tbifc.operand_a);
    $display("  operand_b = %0d\n",tbifc.operand_b);
    $display("  result_rez = %0d\n", result_rez);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", tbifc.read_pointer);
    $display("  opcode = %0d (%s)", tbifc.instruction_word.opc, tbifc.instruction_word.opc.name);
    $display("  operand_a = %0d",   tbifc.instruction_word.op_a);
    $display("  operand_b = %0d\n", tbifc.instruction_word.op_b);
    $display("  result_rez = %0d\n",tbifc.instruction_word.rez);
  endfunction: print_results

   function void check_results;
    case(tbifc.instruction_word.opc)
      ZERO : expected_result_rez = 0;
      PASSA: expected_result_rez= tbifc.instruction_word.op_a;
      PASSB: expected_result_rez= tbifc.instruction_word.op_b;
      ADD  : expected_result_rez= tbifc.instruction_word.op_a + tbifc.instruction_word.op_b;
      SUB  : expected_result_rez= tbifc.instruction_word.op_a - tbifc.instruction_word.op_b;
      MULT : expected_result_rez= tbifc.instruction_word.op_a * tbifc.instruction_word.op_b;
      DIV  : expected_result_rez= tbifc.instruction_word.op_a / tbifc.instruction_word.op_b;
      MOD  : expected_result_rez= tbifc.instruction_word.op_a % tbifc.instruction_word.op_b;
    endcase  
    
    $display("Error_count = %0d\n", err_count ); 
    
    endfunction: check_results

endmodule: instr_register_test
