`timescale 1 ps/ 1 ps

  class uart_driver extends uvm_driver #(uart_trans);
  
    `uvm_component_utils(uart_driver)

    parameter clk_freq = 50000000; //MHz
    parameter baud_rate = 19200; //bits per second
    localparam clock_divide = (clk_freq/baud_rate);

    virtual uart_intf vif;
    reg [7:0] data;
    int no_transactions;
    int count_data;
    
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      // Get interface reference from config database
      if( !uvm_config_db #(virtual uart_intf)::get(this, "", "uart_intf", vif) )
        `uvm_error("", "uvm_config_db::get failed")
    endfunction 
   
    task run_phase(uvm_phase phase);
      forever
      begin
        seq_item_port.get_next_item(req);
        // tx
        vif.tx <= 0;
        count_data = 0;
        repeat($size(req.tx_data_in)+1+req.stop_bit_num)begin
            repeat(req.delitel) begin
                @(posedge vif.clk);
            end
            if (count_data >= 0 && count_data <=7) begin
                vif.tx <= req.tx_data_in[count_data];
                count_data++;
            end
            else if (count_data == 8) begin
                case (req.parity_bit_mode)
                    3'h0: vif.tx <= 0;
                    3'h1: vif.tx <= 1;
                    3'h2: vif.tx <= ~(^req.tx_data_in);
                    3'h3: vif.tx <= ^req.tx_data_in;
                endcase
                count_data++;
            end
            else begin
                vif.tx <= 1;
            end
        end       
        seq_item_port.item_done();
        no_transactions++;
    endtask

  endclass: uart_driver
  



  /*
  1. Сделать счётчик для uart_ce
  2. Сделать конфиг секвенции
  3. Сделать передачу данных
  3.1 Каждый counter == clock_divide передавать бит в intf
  3.2 Каждый раз увеличивать counter_bits
  3.3 Counter_bits == $size(data_from_seq)
  3.4 Считать до тех пор, пока не дойдём до 3.4
  3.5 Передавать вот таким образом vif.tx = data_from_seq[counter_bits]
  3.6 data_from_seq - будет просто массивом, который будет создаваться при sequence_item
  */
