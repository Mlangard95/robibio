close all;clear all;clc;
%% Path for Matlab functions
addpath ('functions/');

%% Global variables (to keep best optimization)
global best_solution;


%% Load dataset
% dataGrimmer contains the data (1000 sample per motion)
% dataGrimmer.{hip|knee|ankle}.{angleDeg|torque|theta|angle}
% N is the number of samples

%motionNames = ["Climbing_ascend"];
%motionNames = ["Climbing_descend"];
%motionNames = ["Cycling"];
%motionNames = ["Lifting_Squat"];
%motionNames = ["Lifting_Stoop"];
%motionNames = ["Recovery"];
%motionNames = ["Running_26"];
%motionNames = ["Running_40"];
%motionNames = ["Sit_to_Stand"];
%motionNames = ["Squat_Jump"];
%motionNames = ["Stairs_ascend"];
%motionNames = ["Stairs_descend"];
%motionNames = [ "Walking_11"];
motionNames = [ "Walking_16"];
[dataGrimmer, N] = loadGrimmerData('./', motionNames);

% plot (dataGrimmer.hip.theta);
% hold on;
% plot (dataGrimmer.hip.angleDeg);


start = 1
step = 1;
stop = N;


%% Robot segments dimensions
dimensions.trunk = [0, 500, 0, 1];
dimensions.thigh = [0, -380, 0, 1];
dimensions.shang = [0, -358, 0, 1];
dimensions.foot = [121, -54, 0, 1];


matrices.translation.hip_to_neck = [1 0 0 dimensions.trunk(1) ; 0 1 0 dimensions.trunk(2); 0 0 1 dimensions.trunk(3); 0 0 0 1];
matrices.translation.hip_to_knee = [1 0 0 dimensions.thigh(1) ; 0 1 0 dimensions.thigh(2); 0 0 1 dimensions.thigh(3); 0 0 0 1];
matrices.translation.knee_to_ankle = [1 0 0 dimensions.shang(1) ; 0 1 0 dimensions.shang(2); 0 0 1 dimensions.shang(3); 0 0 0 1];
matrices.translation.ankle_to_toes = [1 0 0 dimensions.foot(1) ; 0 1 0 dimensions.foot(2); 0 0 1 dimensions.foot(3); 0 0 0 1];

%% Prepare the figure
handle = init_figure_robot()



index = 1;
for i=start:step:stop
    
    
    trajectory.neck = dimensions.trunk;
    set(handle.joint.neck, 'XData', trajectory.neck(1),   'YData', trajectory.neck(2));
    set(handle.segment.trunk,   'XData', [0, trajectory.neck(1)],   'YData', [0, trajectory.neck(2)]);
    
    %% Process Hip
    thetaHip = dataGrimmer.hip.theta(i);
    matrices.rotation.hip = [cos(thetaHip) -sin(thetaHip) 0 0 ; sin(thetaHip), cos(thetaHip), 0, 0; 0,0,1,0; 0, 0, 0, 1];
    
    matrices.transformation.hip_to_knee = matrices.rotation.hip * matrices.translation.hip_to_knee;
    trajectory.knee = matrices.transformation.hip_to_knee * [0;0;0;1];
    
    set(handle.joint.knee, 'XData', trajectory.knee(1),   'YData', trajectory.knee(2));
    set(handle.segment.thigh,   'XData', [0, trajectory.knee(1)],   'YData', [0, trajectory.knee(2)]);
    
    
    %% Process Knee
    thetaKnee = dataGrimmer.knee.theta(i);
    matrices.rotation.knee= [cos(thetaKnee) -sin(thetaKnee) 0 0 ; sin(thetaKnee), cos(thetaKnee), 0, 0; 0,0,1,0; 0, 0, 0, 1];
    
    matrices.transformation.hip_to_ankle = matrices.transformation.hip_to_knee * matrices.rotation.knee * matrices.translation.knee_to_ankle;
    trajectory.ankle = matrices.transformation.hip_to_ankle  * [0;0;0;1];
    
    set(handle.joint.ankle, 'XData', trajectory.ankle(1),   'YData', trajectory.ankle(2));
    set(handle.segment.shang,   'XData', [trajectory.knee(1), trajectory.ankle(1)],   'YData', [trajectory.knee(2), trajectory.ankle(2)]);
    
    
    %% Process Ankle
    thetaAnkle = dataGrimmer.ankle.theta(i);
    matrices.rotation.ankle= [cos(thetaAnkle) -sin(thetaAnkle) 0 0 ; sin(thetaAnkle), cos(thetaAnkle), 0, 0; 0,0,1,0; 0, 0, 0, 1];
    
    matrices.transformation.hip_to_toes = matrices.transformation.hip_to_ankle * matrices.rotation.ankle * matrices.translation.ankle_to_toes;
    trajectory.toes = matrices.transformation.hip_to_toes * [0;0;0;1];
    
    set(handle.joint.toes, 'XData', trajectory.toes(1),   'YData', trajectory.toes(2));
    set(handle.segment.foot,   'XData', [trajectory.ankle(1), trajectory.toes(1)],   'YData', [trajectory.ankle(2), trajectory.toes(2)]);
    
    drawnow();
    
    
end




%% Enable/disable motors
motors.enable.hip = true;
motors.enable.knee = true;
motors.enable.ankle = true;
motors.enable.hip_knee = true;
motors.enable.knee_ankle = true;
id = 0;



%% Boundaries
lb =  [ -85     -100    -80,    50      -100 ...    % Hip { Xh Yh Xl Yl Offset }
    -80     -80     -80,    278     -100 ...        % Knee { Xh Yh Xl Yl Offset }
    -80     -0      -200,   -54     -100 ...        % Ankle { Xh Yh Xl Yl Offset }
    -80     -80     -80,    278     -100 ...        % Hip-Knee { Xh Yh Xl Yl Offset }
    -80    -80      -201,   0       -100];          % Knee-Ankle { Xh Yh Xl Yl Offset }


ub =[   85      500     80      480     100 ...     % Hip { Xh Yh Xl Yl Offset }
    80      480     80,     438     100 ...         % Knee { Xh Yh Xl Yl Offset }
    80      350     -41,    130     100 ...         % Ankle { Xh Yh Xl Yl Offset }
    80      80      80,     438     100 ...         % Hip-Knee { Xh Yh Xl Yl Offset }
    80      80      -39,    134     100];           % Knee-Ankle { Xh Yh Xl Yl Offset }



%% Initial configuration
x= [ -80 , 400, -80, 300, 0 ...     % Hip { Xh Yh Xl Yl Offset }
    80,  300,  80,  300, 0 ...     % Knee { Xh Yh Xl Yl Offset }
    -80,  300,  -180,  20, 0 ...   % Ankle { Xh Yh Xl Yl Offset }
    -50,  100,  -50,  300, 0 ...   % Hip-Knee { Xh Yh Xl Yl Offset }
    -30,  100,  -160,  30, 0 ];    % Knee-Ankle { Xh Yh Xl Yl Offset }



%
% %% Plot initial configuration
% figure; hold on; grid on;
% plot_initial_configuration(x,motors);
% %plot_initial_configuration_bound(x, lb, ub, motors);
% drawnow;
%
% core(motors, dataGrimmer, start, step, stop);
% return;
%
%
% %% Anonymous function for calling the core from fminsearchbnd
% paramCore = @(x)coreOptim(x,motors, dataset, start, step, stop, id);
%
%
% %% Optimization
% disp ('Running optimization, it may really take a while...'); tic
% options = optimset('Display','iter', 'TolFun', 1e-2, 'TolX', 0.1); % 'MaxFunEvals',100);
% [x,fval,exitflag,output] = fminsearchbnd(paramCore,x,lb, ub, options);
% toc

disp ('done')