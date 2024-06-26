class uart_agent extends uvm_agent;
  
 `uvm_component_utils(uart_agent)
    
    uart_sequencer seqr;
    uart_driver    driv;
    uart_mon mon;
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      seqr = uart_sequencer::type_id::create("seqr", this);
      driv = uart_driver::type_id::create("driv", this);
      mon = uart_mon::type_id::create("mon", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      driv.seq_item_port.connect( seqr.seq_item_export);
      // mon.ap_port.connect(cov.analysis_export);
    endfunction
    

endclass
