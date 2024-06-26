// class uart_agent_cfg;
class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	uvm_analysis_port #(uart_trans) ap_port_rx;
	uvm_analysis_port #(uart_trans) ap_port_tx;
    virtual uart_intf uart_intf_u;
    uart_agent_cfg cfg;
	int count_data;
	
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
	  // super.build_phase(phase);
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf_u", uart_intf_u)) 
		    `uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in uart_mon")
      	if( !uvm_config_db #(uart_agent_cfg)::get(this, "", "cfg", cfg) )
            `uvm_error("", "uvm_config_db::get failed")
   		ap_port_rx = new("ap_port_rx",this);
   		ap_port_tx = new("ap_port_tx",this);
	endfunction

  
  task run_phase(uvm_phase phase);
  		logic start_bit;
		$display("csg signals are delitel = %0d, stop_bit_num is %0h, parity_bit_mode = %0h", cfg.delitel, cfg.stop_bit_num, cfg.parity_bit_mode);
		fork
			forever
				begin
					uart_trans trans;
					trans = uart_trans::type_id::create("trans"); 
					@(negedge uart_intf_u.rx)
					#(cfg.t/2);
					start_bit = uart_intf_u.rx;
					repeat(8)begin
						#(cfg.t);
			            if (count_data >= 0 && count_data <=7) begin
			                trans.rx_data_out <= {uart_intf_u.rx, trans.rx_data_out[7:1]};
			                count_data++;
			            end
			            else if (count_data == 8) begin
			                trans.parity_bit <= uart_intf_u.rx;
			                count_data++;
			            end
		        	end
        			$display("trans_tx got is %0h", trans.rx_data_out);
		        	ap_port_rx.write(trans);
				end
			forever	
				begin
					uart_trans trans;
					trans = uart_trans::type_id::create("trans");  
					@negedge uart_intf_u.tx)
					#(cfg.t/2);
					start_bit = uart_intf_u.tx;
					repeat(8)begin
						#(cfg.t);
			            if (count_data >= 0 && count_data <=7) begin
			                trans.rx_data_out <= {uart_intf_u.tx, trans.rx_data_out[7:1]};
			                count_data++;
			            end
			            else if (count_data == 8) begin
			                trans.parity_bit <= uart_intf_u.tx;
			                count_data++;
			            end
		        	end
        			$display("trans_tx got is %0h", trans.rx_data_out);       
		        	ap_port_tx.write(trans);
				end
		join 
      	
  endtask

endclass
