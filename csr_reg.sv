module csr_reg
(
    input  logic         clk,
    input  logic         rst,
    input  logic [31: 0] addr,
    input  logic [31: 0] wdata, // data from rs1
    input  logic [31: 0] pc,
    input  logic         trap_handle,   // Input Interupt Signal
    input  logic         csr_rd, // control signal for read
    input  logic         csr_wr, // control signal for write
    input  logic         is_mret, // control signal for MRET inst
    input  logic [31: 0] inst,
    output logic [31: 0] rdata,
    output logic [31: 0] epc,
    output logic         epc_taken // it's a flag which is fed to the mux right before PC
);

    logic [31: 0] csr_mem [4];
    logic [31:0] mcause = 32'b0;
    logic [31:0] mtvec = 32'b0;
    logic sig =1'b1;

    always_comb
    begin
        if (trap_handle & csr_mem[0][3] & csr_mem[1][7] & csr_mem[3][7]) 
            begin
                epc_taken = 1'b1;
            end
            else
            begin
                epc_taken = 1'b0;
            end
    end
        // asynchronous read
    always_comb
        begin
            if (csr_rd)
            begin
                case (addr)
                    32'h00000300: rdata = csr_mem[0]; // mstatus 
                    32'h00000304: rdata = csr_mem[1]; // mie
                    32'h00000341: rdata = csr_mem[2]; // mepc
                    32'h00000344: rdata = csr_mem[3]; // mip

                    default
                    begin
                        rdata = 32'b0;
                    end
                endcase
            end
        end

    always_comb
        begin
            if (is_mret)
            begin
                epc = csr_mem[2]; // reading the value of 'mepc' register
            end
            else
            begin
                mcause = mcause << 2'd2;
                epc = mcause + mtvec;
            end
        end

    // synchronous write
    always_ff @(negedge clk)
        begin
            if (csr_wr)
            begin
                case (addr)
                    32'h00000300: csr_mem[0] <= wdata; // mstatus
                    32'h00000304: csr_mem[1] <= wdata; // mie
                    32'h00000341: csr_mem[2] <= wdata; // mepc
                    32'h00000344: csr_mem[3] <= wdata; // mip
                endcase
            end
            else
            begin
                if( trap_handle & sig)
                    begin
                        csr_mem[2] <= pc;
                        sig <= 1'b0;
                    end
            end
        end


endmodule