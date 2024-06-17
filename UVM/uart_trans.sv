`timescale 1 ps/ 1 ps

`include "uvm_macros.svh"
import uvm_pkg::*;

  class uart_trans extends uvm_sequence_item;
   
  
    `uvm_object_utils(uart_trans)

	   rand bit   [7:0 ] tx_data_in;
     logic [31:0]      delitel;
     logic [2:0 ]      parity_bit_mode;
     logic             stop_bit_num;
     logic [7:0]       rx_data_out;
     logic             parity_bit;

     constraint c1 {delitel > 0;delitel <= 15;};
  
   
    function new (string name = "uart_trans");
      super.new(name);
    endfunction
    
  endclass: uart_trans


