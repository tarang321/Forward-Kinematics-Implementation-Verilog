`timescale 1ns / 1ps

module tb_forward_kinematics_omni;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    reg signed [15:0] v1, v2, v3;
    reg signed [15:0] r, R;

    wire signed [31:0] Vx, Vy, omega;
    wire done;

    // Instantiate DUT
    forward_kinematics_omni uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .v1(v1),
        .v2(v2),
        .v3(v3),
        .r(r),
        .R(R),
        .Vx(Vx),
        .Vy(Vy),
        .omega(omega),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    integer i;
    initial begin
        $display("Starting simulation...");
        // Reset system
        #10 rst = 0;

        // Set robot parameters
        r = 16'd100;   // Wheel radius
        R = 16'd200;   // Distance to wheel from center

        // Simulate circular path (sinusoidal wheel input pattern)
        for (i = 0; i < 360; i = i + 30) begin
            v1 = $rtoi(100 * $cos(i * 3.14159 / 180.0));  // Cos wave
            v2 = $rtoi(100 * $cos((i + 120) * 3.14159 / 180.0));
            v3 = $rtoi(100 * $cos((i + 240) * 3.14159 / 180.0));

            start = 1;
            #10 start = 0;

            wait (done);
            $display("Angle = %0d° => Vx = %0d, Vy = %0d, omega = %0d", i, Vx, Vy, omega);
            #20;
        end

        $display("Simulation complete.");
        $finish;
    end
endmodule
