module forward_kinematics_omni (
    input clk,
    input rst,
    input start,
    input signed [15:0] v1,
    input signed [15:0] v2,
    input signed [15:0] v3,
    input signed [15:0] r,
    input signed [15:0] R,
    output reg signed [31:0] Vx,
    output reg signed [31:0] Vy,
    output reg signed [31:0] omega,
    output reg done
);
    // Wires for CORDIC outputs
    wire signed [15:0] cos30, sin30;
    wire cordic_done;

    // Angle input in Q1.15 (30 degrees = 30 * 32768 / 180 ? 5461)
    localparam signed [15:0] ANGLE_30_Q15 = 16'd5461;

    // Instantiate CORDIC block for 30 degrees
    cordic_sin_cos cordic_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .angle_in(ANGLE_30_Q15),
        .cos_out(cos30),
        .sin_out(sin30),
        .done(cordic_done)
    );

    reg signed [31:0] term_x, term_y, term_omega;

    always @(posedge clk) begin
        if (rst) begin
            Vx <= 0;
            Vy <= 0;
            omega <= 0;
            done <= 0;
        end else if (cordic_done) begin
            // Vx = r/3 * (-v1 + cos30*v2 + cos30*v3)
            term_x = -v1 + ((v2 * cos30) >>> 15) + ((v3 * cos30) >>> 15);
            Vx <= (r * term_x) / 3;

            // Vy = r/3 * (sin30*v2 - sin30*v3)
            term_y = ((v2 * sin30) >>> 15) - ((v3 * sin30) >>> 15);
            Vy <= (r * term_y) / 3;

            // omega = r / (3R) * (v1 + v2 + v3)
            term_omega = v1 + v2 + v3;
            omega <= (r * term_omega) / (3 * R);

            done <= 1;
        end else begin
            done <= 0;
        end
    end

endmodule
