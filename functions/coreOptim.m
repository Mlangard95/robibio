function [criteria] = coreOptim(x, robot, dataGrimmer, start, step, stop, id)

    global best_solution;
    global indexBest;
    global outputData;
    global gConfigHandler;
    global expe;
    global epoch;


system (sprintf('rm -rf output/expe-%d/epoch-%d', expe, epoch));
mkdir(sprintf('output/expe-%d/epoch-%d', expe, epoch));
hash = randi(1e6);
save(sprintf('output/expe-%d/epoch-%d/hash.mat', expe, epoch),  'hash');
    
    %% Add motor coordinates to structure
    %motors = appendX2motors(x, motors);
    robot.motors.parameters = appendX2motors(x);

    %% Run core
    weight =  core(robot, dataGrimmer, start, step, stop);
    
    
    %% Optimization criteria  
    criteria = -weight;
             
    
    %% Update the best solution if needed
    if (isempty(best_solution) || best_solution > criteria)
        
        
        %% Update and display the best solution
        best_solution = criteria;
        fprintf ('-------------------------------------\n');
        fprintf ('New best solution!\n');
        fprintf ('\tExpe %d\n', expe);
        fprintf ('\tEpoch %d\n', epoch);
        fprintf ('\n');

        fprintf ('\tMax Weight= %.1f kg\n',weight);
        fprintf ('\tCriteria = %f\n',criteria);
        fprintf ('-------------------------------------\n\n\n');
    end
    
    epoch = epoch + 1;

end

