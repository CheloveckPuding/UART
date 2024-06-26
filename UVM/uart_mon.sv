// class uart_agent_cfg;
class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	uvm_analysis_port #(uart_trans) ap_port_rx;
	uvm_analysis_port #(uart_trans) ap_port_tx;
    virtual uart_intf uart_in_intf_u;
    virtual uart_intf uart_out_intf_u;
    uart_agent_cfg cfg;	
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
	  // super.build_phase(phase);
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_out_intf_u", uart_out_intf_u)) 
		    `uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in uart_mon")
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_in_intf_u", uart_in_intf_u)) 
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
					int count_data_rx = 0; 
					uart_trans trans;
					trans = uart_trans::type_id::create("trans");
					trans.data = 0;
					@(negedge uart_in_intf_u.rx);
  					$display("ok",);
					repeat(cfg.delitel/2) begin
						@(posedge uart_in_intf_u.clk);
					end
					start_bit = uart_in_intf_u.rx;
					repeat(10)begin
						repeat(cfg.delitel) begin
							@(posedge uart_in_intf_u.clk);
						end
			            if (count_data_rx >= 0 && count_data_rx <=7) begin
			                trans.data = {uart_in_intf_u.rx, trans.data[7:1]};
			                count_data_rx++;
			            end
			            else if (count_data_rx == 8) begin
			                trans.parity_bit = uart_in_intf_u.rx;
			                count_data_rx++;
			            end
		        	end
        			$display("trans_rx got is %0h", trans.data);
		        	ap_port_rx.write(trans);
				end
			forever	
				begin
					int count_data_tx = 0; 
					uart_trans trans;
					trans = uart_trans::type_id::create("trans");
					trans.data = 0;
					@(negedge uart_out_intf_u.tx);
					repeat(cfg.delitel/2) begin
						@(posedge uart_out_intf_u.clk);
					end
					start_bit = uart_out_intf_u.tx;
					repeat(10)begin
						repeat(cfg.delitel) begin
							@(posedge uart_out_intf_u.clk);
						end
			            if (count_data_tx >= 0 && count_data_tx <=7) begin
			                trans.data = {uart_out_intf_u.tx, trans.data[7:1]};
			                $display("trans_tx is %0h",uart_out_intf_u.tx);
			                count_data_tx++;
			                $display("ok_counter is %0h", count_data_tx);
							$display("trans_tx right now is  %0h", trans.data);       

			            end
			            else if (count_data_tx == 8) begin
			                trans.parity_bit = uart_out_intf_u.tx;
			                count_data_tx++;
			            end
		        	end
        			$display("trans_tx got is %0h", trans.data);       
		        	ap_port_tx.write(trans);
				end
		join 
  endtask
  // task get_rx(logic bit) begin
  	
  // end
endclass
