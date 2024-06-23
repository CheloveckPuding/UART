`timescale 1 ps/ 1 ps

`include "uvm_macros.svh"
import uvm_pkg::*;

  class uart_trans extends uvm_sequence_item;
   
  
    `uvm_object_utils(uart_trans)

     rand bit   [7:0] tx_data_in;
     rand logic [7:0] rx_data_out;
     rand logic       parity_bit;
  
   
    function new (string name = "uart_trans");
      super.new(name);
    endfunction
    
  endclass: uart_trans


