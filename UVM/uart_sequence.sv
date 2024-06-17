`timescale 1 ps/ 1 ps

class uart_sequencer extends uvm_sequencer #(uart_trans);
  
    `uvm_object_utils(uart_sequencer)
    int count;
    
    function new (string name = ""); 
      super.new(name);
    endfunction

      function void build_phase (uvm_phase phase);
        super.build_phase(phase);
      endfunction

    // task body;
    //   if (starting_phase != null)
    //     starting_phase.raise_objection(this);
    //     void'(uvm_config_db #(int)::get(null,"","no_of_transactions",count));
    //   repeat(count)
    //   begin
    //     req = uart_trans::type_id::create("req");
    //     start_item(req);
    //     if( !req.randomize() )
    //       `uvm_error("", "Randomize failed")
    //     finish_item(req);
    //   end
      
    //   if (starting_phase != null)
    //     starting_phase.drop_objection(this);
    // endtask: body
   
  endclass: uart_sequencer
  
