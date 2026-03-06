module SPI_protocol(
       input wire clk,
       input wire rst,
       input wire start,
       input wire cshold,
       input wire miso, 
       input wire wdelay_enable,
       input wire [7:0]data_tx,
       output reg mosi,
       
       
       output reg sclk,
       output reg cs,
       output reg [7:0]data_rx,
       output reg done
    );
     parameter c2t_d=4;
       parameter t2c_d=4;
       parameter w_delay=6;
       
       reg[7:0]tx_shift,rx_shift;
       reg[2:0] bit_cnt;
       reg [7:0] delay_cnt;
       reg[2:0] state;
       localparam IDLE=3'd0,
                  CS_SETUP=3'd1,
                  TRANSFER=3'd2,
                  CS_HOLD=3'd3,
                  WAIT_SPI=3'd4; 
                  
        reg clk_div;
        always@(posedge clk)begin
              if(rst)
                clk_div<=1'b0;
              else
                 clk_div<=~clk_div;
        end
        
        always@(posedge clk_div)begin
              if(rst)begin
                 cs<=1'b1;
                 mosi<=1'b0;
                 done<=1'b0;
                 sclk<=1'b0;
                 data_rx<=8'd0;
                 state<=IDLE;
              end
              else begin
                  case(state)
                  
                  IDLE:begin
                      done<=1'b0;
                      sclk<=1'b0;
                      if(start)begin
                         cs<=1'b0;
                         tx_shift<=data_tx;
                         bit_cnt<=3'd7;
                         delay_cnt<=c2t_d;
                         if(cshold==1'b1)begin
                            state<=TRANSFER;
                         end
                         else 
                            state<=CS_SETUP;
                         end
                      end
                      
                  CS_SETUP:begin
                      if(delay_cnt==1'b0)begin 
                        state <= TRANSFER;
                      end
                       else 
                          delay_cnt<=delay_cnt-1'b1;
                       end
                 
                 TRANSFER: begin
                           sclk <= ~sclk;
                           if (sclk == 1'b1) begin
                               if (bit_cnt == 0) begin
                                   delay_cnt <= t2c_d;
                                   state <= (cshold) ? WAIT_SPI : CS_HOLD;
                               end else begin
                                   bit_cnt <= bit_cnt - 1'b1;
                               end
                           end else begin 
                               rx_shift[bit_cnt] <= miso; 
                               mosi <= tx_shift[bit_cnt];
                           end
                       end
                       
                       CS_HOLD: begin
                           sclk <= 1'b0;
                           if (delay_cnt == 0) begin
                               cs <= 1'b1;
                               data_rx <= rx_shift; 
                               done <= 1'b1;
                               state <= IDLE;
                           end else begin
                               delay_cnt <= delay_cnt - 1'b1;
                           end
                       end
                 
                 WAIT_SPI:begin
                     if(delay_cnt==0)begin
                        if(cshold==1'b0)begin
                           cs<=1'd1;
                           data_rx<=rx_shift;
                           done<=1'b1;
                           state<=IDLE;
                         end
                         else begin
                             delay_cnt<=delay_cnt-1'b1;
                         end
                      end
                    end
                  default: begin
                     state<=IDLE;
                  end
               endcase      
             end
           end

endmodule
