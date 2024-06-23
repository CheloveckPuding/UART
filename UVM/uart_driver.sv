`timescale 1 ps/ 1 ps

  class uart_driver extends uvm_driver #(uart_trans);
  
    `uvm_component_utils(uart_driver)

    virtual uart_intf uart_intf_u;
    uvm_uart_cfg_sequence cfg;
    reg [7:0] data;
    int no_transactions;
    int count_data;
    
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      // Get interface reference from config database
      if( !uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf_u", uart_intf_u) )
        `uvm_error("", "uvm_config_db::get failed")
      if( !uvm_config_db #(uvm_uart_cfg_sequence)::get(this, "", "cfg", cfg) )
            `uvm_error("", "uvm_config_db::get failed")
    endfunction 
   
    task run_phase(uvm_phase phase);
        uart_intf_u.tx <= 1;
        count_data = 0;
        forever
        begin
            uart_trans req;
            seq_item_port.get_next_item(req);
            // tx
            repeat($size(req.tx_data_in)+2+cfg.stop_bit_num)begin
                #cfg.t;
                if (count_data >= 0 && count_data <= 8) begin
                    if (count_data == 0) begin
                        uart_intf_u.tx <= 0;
                    end
                    else begin 
                        uart_intf_u.tx <= req.tx_data_in[count_data];
                    end
                    count_data++;
                end
                else if (count_data == 9) begin
                    case (cfg.parity_bit_mode)
                        3'h0: uart_intf_u.tx <= 0;
                        3'h1: uart_intf_u.tx <= 1;
                        3'h2: uart_intf_u.tx <= ~(^cfg.tx_data_in);
                        3'h3: uart_intf_u.tx <= ^cfg.tx_data_in;
                    endcase
                    count_data++;
                end
                else begin
                    uart_intf_u.tx <= 1;
                end
            end       
            seq_item_port.item_done();
            no_transactions++;
        end
    endtask

  endclass: uart_driver