`timescale 1ns/10ps
class uart_mon extends uvm_monitor;
	`uvm_component_utils(uart_mon)
	
	uvm_analysis_port #(uart_trans) ap_port_rx;
	uvm_analysis_port #(uart_trans) ap_port_tx;
    virtual uart_intf uart_intf_u;
    uart_agent_cfg cfg;	
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction


	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf_u", uart_intf_u)) 
		    `uvm_error("ERROR::", "UVM_CONFIG_DB FAILED in uart_mon")
      	if( !uvm_config_db #(uart_agent_cfg)::get(this, "", "cfg", cfg) )
            `uvm_error("", "uvm_config_db::get failed")
   		ap_port_rx = new("ap_port_rx",this);
   		ap_port_tx = new("ap_port_tx",this);
	endfunction

  
  task run_phase(uvm_phase phase);
  		logic start_bit;
		fork
			forever
				begin
					int count_data_rx = 0;
					uart_trans trans;
					trans = uart_trans::type_id::create("trans");
					trans.data = 0;
					@(negedge uart_intf_u.rx);
					#(cfg.t/2);
					start_bit = uart_intf_u.rx;
					repeat(10+cfg.stop_bit_num)begin
						#(cfg.t);
			            if (count_data_rx >= 0 && count_data_rx <=7) begin
			                trans.data = {uart_intf_u.rx, trans.data[7:1]};
			                count_data_rx++;
			            end
			            else if (count_data_rx == 8) begin
			                case (cfg.parity_bit_mode)
								3'h0: begin
									if (uart_intf_u.rx != 0) begin
										`uvm_error("UART_MON_RX", "PARITY_BIT IS IUNCORRECT");
									end
								end
								3'h1: begin
									if (uart_intf_u.rx != 1) begin
										`uvm_error("UART_MON_RX", "PARITY_BIT IS IUNCORRECT");
									end
								end
								3'h2: begin
									if (uart_intf_u.rx != ~(^trans.data)) begin
										`uvm_error("UART_MON_RX", "PARITY_BIT IS IUNCORRECT");
									end
								end
								3'h3: begin
									if (uart_intf_u.rx != ^trans.data) begin
										`uvm_error("UART_MON_RX", "PARITY_BIT IS IUNCORRECT");
									end
								end
							endcase
			                count_data_rx++;
			            end
			            else begin
			            	$display("stop_bit");
			            	if (~uart_intf_u.rx) begin
			            		`uvm_error("UART_MON_RX", "STOP_BIT_ERR");
			            	end
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
					@(negedge uart_intf_u.tx);
					#(cfg.t/2);
					start_bit = uart_intf_u.tx;
					repeat(10+cfg.stop_bit_num)begin
						#(cfg.t);
			            if (count_data_tx >= 0 && count_data_tx <=7) begin
			                trans.data = {uart_intf_u.tx, trans.data[7:1]};
			                count_data_tx++;     

			            end
			            else if (count_data_tx == 8) begin
			                case (cfg.parity_bit_mode)
								3'h0: begin
									if (uart_intf_u.tx != 0) begin
										`uvm_error("UART_MON_TX", "PARITY ERROR")
									end
								end
								3'h1: begin
									if (uart_intf_u.tx != 1) begin
										`uvm_error("UART_MON_TX", "PARITY ERROR")
									end
								end
								3'h2: begin
									if (uart_intf_u.tx != ~(^trans.data)) begin
										`uvm_error("UART_MON_TX", "PARITY ERROR")
									end
								end
								3'h3: begin
									if (uart_intf_u.tx != ^trans.data) begin
										`uvm_error("UART_MON_TX", "PARITY ERROR")
									end
								end
							endcase
			                count_data_tx++;
			            end
			            else begin
			            	if (~uart_intf_u.tx) begin
			            		`uvm_error("UART_MON_TX", "STOP_BIT_ERR");
			            	end
			            	else begin 
			            		$display("stop_bit",);
			            	end
			            end
		        	end
        			$display("trans_tx got is %0h", trans.data);       
		        	ap_port_tx.write(trans);
				end
		join 
  endtask
endclass
