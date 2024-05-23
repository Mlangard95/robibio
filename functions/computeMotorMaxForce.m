function [maxForces, status] = computeMotorMaxForce(robot)
    % Distance between attachment points
    [maxForces.hip, status.hip] = P02_23x80F_HP (robot.motors.lengths.hip - robot.motors.parameters.hip.offset(1), robot.motors.sliderLength.hip);
    [maxForces.knee, status.knee]  = P02_23x80F_HP (robot.motors.lengths.knee - robot.motors.parameters.knee.offset(1), robot.motors.sliderLength.knee);
    [maxForces.ankle, status.ankle]  = P02_23x80F_HP (robot.motors.lengths.ankle - robot.motors.parameters.ankle.offset(1), robot.motors.sliderLength.ankle);
    [maxForces.hip_knee, status.hip_knee]  = P02_23x80F_HP (robot.motors.lengths.hip_knee - robot.motors.parameters.hip_knee.offset(1), robot.motors.sliderLength.hip_knee);
    [maxForces.knee_ankle, status.knee_ankle]  = P02_23x80F_HP (robot.motors.lengths.knee_ankle - robot.motors.parameters.knee_ankle.offset(1), robot.motors.sliderLength.knee_ankle);
end

