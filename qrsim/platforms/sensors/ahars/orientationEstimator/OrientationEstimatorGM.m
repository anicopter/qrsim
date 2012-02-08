classdef OrientationEstimatorGM<OrientationEstimator
    % Simple orientation noise model.
    % The following assumptions are made:
    % - the noise is modelled as an additive Gauss-Markov process.
    % - the accelerometer refrence frame concides wih the body reference frame
    % - no time delays
    %
    % OrientationEstimatorGM Properties:
    %   BETA                              - noise time constant
    %   SIGMA                             - noise standard deviation
    %
    % OrientationEstimatorGM Methods:
    %   OrientationEstimatorGM(objparams) - constructs the object
    %   getMeasurement(X)                 - returns a noisy orientation measurement
    %   update(X)                         - updates the orientation sensor noisy measurement
    %   reset()                           - reinitializes the noise state         
    %   setState(X)                       - sets the current orientation and resets
    %
    properties (Access = private)
        BETA;                             % noise time constant
        SIGMA;                            % noise standard deviation
        n = zeros(3,1);                   % noise sample at current timestep
        estimatedOrientation = zeros(3,1);% measurement at last valid timestep        
        nPrngId;                          %id of the prng stream used by the noise model
        rPrngId;                          %id of the prng stream used to spin up the noise model
    end
    
    methods (Sealed)
        function obj = OrientationEstimatorGM(objparams)
            % constructs the object
            %
            % Example:
            %
            %   obj=OrientationEstimatorGM(objparams)
            %                objparams.dt - timestep of this object
            %                objparams.on - 1 if the object is active
            %                objparams.BETA - noise time constant
            %                objparams.SIGMA - noise standard deviation
            %
            global state;
            
            obj=obj@OrientationEstimator(objparams);                       

            obj.nPrngId = state.numRStreams+1;
            obj.rPrngId = state.numRStreams+2; 
            state.numRStreams = state.numRStreams + 2;
            
            assert(isfield(objparams,'BETA'),'orientationestimatorgm:nobeta',...
                'the platform config file a must define orientationEstimator.BETA parameter');
            obj.BETA = objparams.BETA;    % noise time constant
            assert(isfield(objparams,'SIGMA'),'orientationestimatorgm:nosigma',...
                'the platform config file a must define orientationEstimator.SIGMA parameter');
            obj.SIGMA = objparams.SIGMA;  % noise standard deviation
        end
        
        function estimatedOrientation = getMeasurement(obj,~)
            % returns a noisy orientation measurement
            %
            % Example:
            %   mo = obj.getMeasurement(X)
            %        X - platform noise free state vector [px;py;pz;phi;theta;psi;u;v;w;p;q;r;thrust]
            %        mo - 3 by 1 "noisy" orientation in global frame,
            %             Euler angles ZYX [~phi;~theta;~psi] rad
            %
            estimatedOrientation = obj.estimatedOrientation;
        end
        
                
        function obj=reset(obj)
            % reinitializes the noise state
            global state;
            
            obj.n = 0;
            for i=1:randi(state.rStreams{obj.rPrngId},1000)
                obj.n = obj.n.*exp(-obj.BETA*obj.dt) + obj.SIGMA.*sqrt((1-exp(-2*obj.BETA*obj.dt))./(2*obj.BETA)).*randn(state.rStreams{obj.nPrngId},3,1);
            end
        end
    end
    
    methods (Sealed,Access=protected)
        function obj=update(obj,X)
            % updates the orientation sensor noise state
            % Note: this method is called by step() if the time is a multiple
            % of this object dt, therefore it should not be called directly.
            global state;
            obj.n = obj.n.*exp(-obj.BETA*obj.dt) + obj.SIGMA.*sqrt((1-exp(-2*obj.BETA*obj.dt))./(2*obj.BETA)).*randn(state.rStreams{obj.nPrngId},3,1);
            obj.estimatedOrientation = obj.n + X(4:6);
        end
    end
    
end

