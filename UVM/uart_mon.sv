class uart_mon extends uvm_monitor;
	
	virtual uart_intf intf;
	uart_trans trans;
	uvm_analysis_port #(uart_trans) ap_port;
	`uvm_component_utils(uart_mon)
	int count_data;
	
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
	  super.build_phase(phase);
	  ap_port = new("ap_port",this);
	  trans = uart_trans::type_id::create("trans");
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", intf)) 
		   begin
		    `uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in uart_mon")
		    end
		//ap_port = new("ap_port", this);
	endfunction

  
  task run_phase(uvm_phase phase);
		forever
		begin 
			@(negedge intf.rx)
			repeat(8)begin
	            repeat(trans.delitel) begin
	                @(posedge vif.clk);
	            end
	            if (count_data >= 0 && count_data <=7) begin
	                trans.rx_data_out <= {vif.rx, trans.rx_data_out[7:1]};
	                count_data++;
	            end
	            else if (count_data == 8) begin
	                trans.parity_bit <= vif.rx;
	                count_data++;
	            end
        	end       
      	ap_port.write(trans);
    end
  endtask

endclass
