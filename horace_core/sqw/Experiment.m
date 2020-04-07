classdef Experiment
    %EXPERIMENT Container object for all data describing the Experiment
    
    properties(Access=private)
        instruments_ = []
        detector_array_ = []
        sample_ = []
    end
    
    properties (Dependent)
        % Mirrors of private properties
        instruments
        detector_array
        sample
    end
    
    methods
        function obj = Experiment(detector_array, instruments, sample)
            % Create a new Experiment object.
            %
            %   obj = Experiment (detector_array(s), instrument(s), sample(s))
            %
            %   detector_array  Detector array (IX_detector_array objects)
            %   instrument      Instrument (Concrete class inheriting IX_inst)
            %   sample          Sample data (IX_sample object)
            %
            % Each argument can be a single object or array of objects.
            
            obj.detector_array = detector_array;
            obj.instruments = instruments;
            obj.sample = sample;            
        end
                
        function obj=set.detector_array_(obj,val)
            if isa(val,'IX_detector_array') 
                obj.detector_array_ = val;
            else
                error('Detector array must be one or an array of IX_detector_array object')
            end
        end
        
        function obj=set.instruments_(obj,val)
            if isa(val,'IX_inst')
                obj.instruments_ = val;
            else
                error('Instruments must be one or an array of IX_inst objects')
            end
        end
        
        function obj=set.sample_(obj,val)
            if isa(val,'IX_sample') 
                obj.sample_ = val;
            else
                error('Sample must be one or an array of IX_sample objects')
            end
        end
        
        function val=get.detector_array(obj)
            val=obj.detector_array_;
        end
        function obj=set.detector_array(obj, val)
            obj.detector_array_ = val;
        end
        
        function val=get.instruments(obj)
            val=obj.instruments_;
        end
        function obj=set.instruments(obj, val)
            obj.instruments_ = val;
        end
        
        function val=get.sample(obj)
            val=obj.sample_;
        end
        function obj=set.sample(obj, val)
            obj.sample_ = val;
        end
    end
end

