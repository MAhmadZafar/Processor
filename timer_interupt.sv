module timer (
    input  logic clk,
    input  logic rst,
    output logic timer_interupt
);
    parameter TIMER_LIMIT = 2; // clock frequency

    reg [31:0] timer_counter;
    logic single_cycle = 1'b1;
    
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            timer_counter <= 0;
        end
        else
        begin
            timer_counter <= timer_counter + 1;
            if (timer_counter == TIMER_LIMIT & single_cycle)
            begin
                timer_counter <= 0;
                timer_interupt <= 1;
                single_cycle = 1'b0;
            end
            else
            begin
                timer_interupt <= 0;
            end
        end
    end

endmodule