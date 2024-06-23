class uvm_uart_cfg_sequence extends uvm_sequence#(uart_trans);
  
  `uvm_object_utils(uvm_uart_cfg_sequence)

  uart_trans transaction;

  function new (string name = "");
    super.new(name);
  endfunction

  task body();
    begin
      transaction = new();
      start_item(transaction);
      assert(transaction.randomize());
      finish_item(transaction);
    end
  endtask
endclass