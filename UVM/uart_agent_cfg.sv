class uvm_uart_cfg_sequence extends  uvm_object;
    `uvm_object_utils(uvm_uart_cfg_sequence)
    
    function new (string name = "");
        super.new(name);
    endfunction

    parameter CLOCK_PERIOD = 10;
    
    rand int unsigned numb_trans;
    rand logic [31:0] delitel;
    rand logic [2:0]  parity_bit_mode;
    rand logic        stop_bit_num;
    time              t = delitel * CLOCK_PERIOD;  

    constraint del {delitel > 0; delitel < 15;}


endclass : uvm_uart_cfg_sequence