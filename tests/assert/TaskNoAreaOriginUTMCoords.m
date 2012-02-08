classdef TaskNoAreaOriginUTMCoords<Task
    % Task used to test assertions on DT
    %
    methods (Sealed,Access=public)
        
        function taskparams=init(obj)
            % loads and returns all the parameters for the various simulator objects
            
            % Simulator step time in second this should not be changed...
            taskparams.DT = 0.02;
            
            taskparams.seed = 0; %set to zero to have a seed that depends on the system time
            
            %%%%% visualization %%%%%
            % 3D display parameters
            taskparams.display3d.on = 0;
            taskparams.display3d.width = 1000;
            taskparams.display3d.height = 600;            
            
            %%%%% environment %%%%%
            % these need to follow the conventions of axis(), they are in m, Z down
            taskparams.environment.area.limits = [-10 20 -7 7 -20 0];
            taskparams.environment.area.type = 'BoxArea';
            
        end
        
        function r=reward(obj) 
            % nothing this is just a test task
        end
    end
    
end