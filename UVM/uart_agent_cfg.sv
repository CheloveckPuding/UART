class uart_agent_cfg extends  uvm_object;
    `uvm_object_utils(uart_agent_cfg)
    
    function new (string name = "");
        super.new(name);
    endfunction

    parameter CLOCK_PERIOD = 10;
    
    rand int unsigned numb_trans;
    rand logic [31:0] delitel;
    rand logic [2:0]  parity_bit_mode;
    rand logic        stop_bit_num;
    rand time         t; 

    constraint del    {delitel         >  0; delitel         < 15;}
    constraint parity {parity_bit_mode >= 0; parity_bit_mode <= 3;}
    constraint tim    {t == delitel * CLOCK_PERIOD;}


endclass : uart_agent_cfg