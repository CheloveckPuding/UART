class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	uvm_analysis_port #(uart_trans) ap_port;
	uart_trans trans;
    virtual uart_intf uart_intf_u;
    uvm_uart_cfg_sequence cfg;
	int count_data;
	
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
	  // super.build_phase(phase);
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf_u", uart_intf_u)) 
		    `uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in uart_mon")
      	if( !uvm_config_db #(uvm_uart_cfg_sequence)::get(this, "", "cfg", cfg) )
            `uvm_error("", "uvm_config_db::get failed")
   		ap_port = new("ap_port",this);
	    trans = uart_trans::type_id::create("trans");
		//ap_port = new("ap_port", this);
	endfunction

  
  task run_phase(uvm_phase phase);
		$display("csg signals are delitel = %0d, stop_bit_num is %0h, parity_bit_mode = %0h", cfg.delitel, cfg.stop_bit_num, cfg.parity_bit_mode);
		forever
		begin 
			@(negedge uart_intf_u.rx)
			repeat(8)begin
	            #cfg.t;
	            if (count_data >= 0 && count_data <=7) begin
	                trans.rx_data_out <= {uart_intf_u.rx, trans.rx_data_out[7:1]};
	                count_data++;
	            end
	            else if (count_data == 8) begin
	                trans.parity_bit <= uart_intf_u.rx;
	                count_data++;
	            end
        	end
        	$display("trans got is %0h", trans.rx_data_out);       
      	ap_port.write(trans);
    end
  endtask

endclass
