classdef PelicanWithCamera<Pelican
    % Class that implementatios dynamic and sensors of an AscTec Pelican quadrotor
    % with an onboard visual camera.
    % The parameters are derived from the system identification of one of
    % the UCL quadrotors
    %
    % Pelican Properties:
    % X   - state = [px;py;pz;phi;theta;psi;u;v;w;p;q;r;thrust]
    %       px,py,pz         [m]     position (NED coordinates)
    %       phi,theta,psi    [rad]   attitude in Euler angles right-hand ZYX convention
    %       u,v,w            [m/s]   velocity in body coordinates
    %       p,q,r            [rad/s] rotational velocity  in body coordinates
    %       thrust           [N]     rotors thrust
    %
    % eX  - estimated state = [~px;~py;~pz;~phi;~theta;~psi;0;0;0;~p;~q;~r;0;~ax;~ay;~az;
    %                          ~h;~pxdot;~pydot;~hdot]
    %       ~px,~py,~pz      [m]     position estimated by GPS (NED coordinates)
    %       ~phi,~theta,~psi [rad]   estimated attitude in Euler angles right-hand ZYX convention
    %       0,0,0                    placeholder (the uav does not provide velocity estimation)
    %       ~p,~q,~r         [rad/s] measured rotational velocity in body coordinates
    %       0                        placeholder (the uav does not provide thrust estimation)
    %       ~ax,~ay,~az      [m/s^2] measured acceleration in body coordinates
    %       ~h               [m]     estimated altitude from altimeter NED, POSITIVE UP!
    %       ~pxdot           [m/s]   x velocity from GPS (NED coordinates)
    %       ~pydot           [m/s]   y velocity from GPS (NED coordinates)
    %       ~hdot            [m/s]   altitude rate from altimeter (NED coordinates)
    %
    % U   - controls  = [pt,rl,th,ya,bat]
    %       pt  [-0.89..0.89]  [rad]   commanded pitch
    %       rl  [-0.89..0.89]  [rad]   commanded roll
    %       th  [0..1]         unitless commanded throttle
    %       ya  [-4.4,4.4]     [rad/s] commanded yaw velocity
    %       bat [9..12]        [Volts] battery voltage
    %
    % Pelican Methods:
    %    Pelican(objparams) - constructs object
    %    reset()            - resets all the platform subcomponents
    %    setX(X)            - reinitialise the current state and noise
    %    isValid()          - true if the state is valid
    %    getX()             - returns the state (noiseless)
    %    getEX()            - returns the estimated state (noisy)
    %    getEXasX()         - returns the estimated state (noisy) formatted as the noiseless state    
    %    getCameraOutput()  - returns the camera output
    
    properties (Access = protected)
        camera;       % handle to the camera
        cameraOutput; % last valid measurement from the camera
    end
    
    methods (Access = public)
        function obj = PelicanWithCamera(objparams)
            % constructs the platform object and initialises its subcomponent
            % The configuration of the type and parameters of the subcomponents are read
            % from the platform config file e.g. pelican_config.m
            %
            % Example:
            %
            %   obj=PelicanWithCamera(objparams);
            %                objparams.dt - timestep of this object
            %                objparams.on - 1 if the object is active
            %                objparams.aerodynamicturbulence - aerodynamicturbulence parameters
            %                objparams.sensors.ahars - ahrs parameters
            %                objparams.sensors.gpsreceiver - gps receiver parameters
            %                objparams.graphics - graphics parameters
            %                objparams.camera - camera parameters
            %                objparams.stateLimits - 13 by 2 vector of allowed values of the state
            %                objparams.collisionDistance - distance from any other object that defines a collision
            %                objparams.dynNoise -  standard deviation of the noise dynamics
            %                objparams.state - handle to simulator state
            %
            
            obj=obj@Pelican(objparams);
            
            % camera
            assert(isfield(objparams,'camera')&&isfield(objparams.camera,'on'),'pelican:nocamera',...
                'the platform config file must define a camera parameter');
            obj.camera = feval(objparams.sensors.camera.type,objparams.sensors.camera);           
        end
        
        function obj = resetAdditional(obj)
            % resets all the platform specific subcomponents
            %
            % Example:
            %   obj.reset();
            %
            obj.camera.reset();
        end        
        
        function o = getCameraOutput(obj)
            % return the last result from the camera, mind that this is
            % updated at the camera frame rate
            o = obj.cameraOutput; 
        end    
    end
    
    methods (Access=protected)
        function obj = updateAdditional(obj,~)
            % updates the component that are not standard
            %
            % Note:
            %  this method is called automatically by update() of the
            %  parent class
            %
            
            % camera
            obj.camera.step(obj.X);
                    
            obj.cameraOutput = obj.camera.getMeasurement(obj.X);
        end          
    end
end
