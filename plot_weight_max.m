close all;clear all;clc;
%% Path for Matlab functions
addpath ('functions/');



global expe;
expe = 0;
global epoch;
epoch = 1;
global step;
step = 1;

isOver = 0;



while (isOver~=1)
    
    filename = sprintf('output/expe-%d/epoch-%d/step-%d.mat', expe, epoch, step);
    if (isfile(filename))
        load(filename)
        data.weight.hip(step) = min(robot.weight_max.hip, 300);
        data.weight.knee(step) = min(robot.weight_max.knee, 300);
        data.weight.ankle(step) = min(robot.weight_max.ankle, 300);

        data.weight.global(step) = robot.weight_max.global;

        step = step+1;
    else
        isOver = 1;
    end
    
end

figure;

subplot(4,1,1); hold on;
plot (data.weight.hip);

grid on;
title ('Hip Max Weight');

subplot(4,1,2);  hold on;
plot (data.weight.knee);

grid on;
title ('Knee Max Weight');

subplot(4,1,3);  hold on;
plot (data.weight.ankle);
grid on;
title ('Ankle Max Weight');

subplot(4,1,4); hold on;
plot (data.weight.global);
grid on;
title ('Max Weight');


disp (sprintf('Max weight : %.2f kg', min(data.weight.global)))

