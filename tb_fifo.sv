`timescale 1ns/1ps

module tb_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
);

    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic full;
    logic empty;
    logic [DATA_WIDTH-1:0] data_out;

    logic [DATA_WIDTH-1:0] expected [0:DEPTH-1];

    // Instantiate the FIFO module under test
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .full(full),
        .empty(empty),
        .data_out(data_out)
    );

    // Generate a 100 MHz clock (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 ns
    end 

    initial begin
        // Initialize signals
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Apply reset
        #10 rst_n = 1;

        // Write some data into the FIFO
        for (int i = 0; i < DEPTH; i++) begin
            @(negedge clk);
            wr_data = $urandom_range(0, 255);
            expected[i] = wr_data;
            wr_en = 1;

            @(negedge clk);
            wr_en = 0;
        end

        if(full !== 1) begin
            $fatal(1, "Error: FIFO should be full after writing %0d items", DEPTH);
        end

        // Read data from the FIFO
        for (int i = 0; i < DEPTH; i++) begin
            @(negedge clk);
            rd_en = 1;
            @(posedge clk);
            #1; // Wait for the registered output to update

            if (data_out !== expected[i])
                $fatal(1, "Read %0d: expected %h, received %h", i, expected[i], data_out);


            @(negedge clk);
            rd_en = 0;
        end

        if(empty !== 1) begin
            $fatal(1, "Error: FIFO should be empty after reading %0d items", DEPTH);
        end

        //write 2 more data to the FIFO
        for (int i = 0; i < 2; i++) begin
            @(negedge clk);
            wr_data = $urandom_range(0, 255); // Random data for testing
            wr_en = 1;
            @(negedge clk);
            wr_en = 0;
        end 

        //Try to read and write at the same time
        @(negedge clk);
        wr_data = $urandom_range(0, 255);
        wr_en = 1;
        rd_en = 1;

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;  




        // Finish simulation
        #10 $finish;
    end 

    initial begin
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_fifo);
    end 

    initial begin
        $monitor("Time: %0t | wr_en: %b | rd_en: %b | wr_data: %h | data_out: %h | full: %b | empty: %b", 
                 $time, wr_en, rd_en, wr_data, data_out, full, empty);
    end 



endmodule