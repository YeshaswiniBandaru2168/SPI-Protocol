module SPI_protocol_tb();
    reg clk;
    reg rst;
    reg start;
    reg cshold;
    reg miso;
    reg wdelay_enable;
    reg [7:0] data_tx;

    wire mosi;
    wire sclk;
    wire cs;
    wire [7:0] data_rx;
    wire done;
    
    SPI_protocol uut (
            .clk(clk), 
            .rst(rst), 
            .start(start), 
            .cshold(cshold), 
            .miso(miso), 
            .wdelay_enable(wdelay_enable), 
            .data_tx(data_tx), 
            .mosi(mosi), 
            .sclk(sclk), 
            .cs(cs), 
            .data_rx(data_rx), 
            .done(done)
        );
        initial clk = 0;
        always #5 clk = ~clk;
    
        reg [7:0] slave_shift_reg = 8'hA5;
        
        always @(posedge sclk) begin
            if (!cs) begin
                miso <= slave_shift_reg[7];
                slave_shift_reg <= {slave_shift_reg[6:0], mosi};
            end
        end
    
        initial begin
            rst = 1;
            start = 0;
            cshold = 0;
            miso = 0;
            wdelay_enable = 0;
            data_tx = 8'h00;
    
            #20;
            rst = 0;
            #20;
    
            data_tx = 8'h3C; 
            start = 1;    
            #20;            
            start = 0;      
    
            wait(done == 1);
            $display("Transaction 1 Complete!");
            $display("Sent: 0x3C, Received: 0x%h", data_rx);
            
            #100;
    
            slave_shift_reg = 8'h5A; 
            data_tx = 8'hFF;
            start = 1;
            #20;
            start = 0;
    
            wait(done == 1);
            $display("Transaction 2 Complete!");
            $display("Sent: 0xFF, Received: 0x%h", data_rx);
    
            #200;
            $finish; 
        end

endmodule
