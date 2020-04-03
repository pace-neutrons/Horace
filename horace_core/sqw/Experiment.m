classdef Experiment
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        instruments_ = {}
        detector_array_ = {}
        sample_ = {}
    end
    
    properties (Dependent)
        % Mirrors of private properties
        instruments
        detector_array
        sample
    end
    
    methods
        function obj = Experiment(detector_array, instruments, sample)
            %EXPERIMENT Construct an instance of this class
            %   Detailed explanation goes here
            obj.detector_array = detector_array;
            obj.instruments = instruments;
            obj.sample = sample;            
        end
        
        
        function obj=set.detector_array_(obj,val)
            if isa(val,'IX_detector_array') 
                if isscalar(val)
                    obj.detector_array_ = { val };
                else
                    obj.detector_array_ = val;
                end
            else
                error('Detector array must be an IX_detector_array object')
            end
        end
        function obj=set.instruments_(obj,val)
            if isa(val,'IX_Instr') && isscalar(val)
                obj.instruments_= [ val] ;
            else
                error('Instruments must be an IX_Instr object')
            end
        end
        function obj=set.sample_(obj,val)
            if isa(val,'IX_sample') && isscalar(val)
                obj.sample_=val;
            else
                error('Instruments must be an IX_sample object')
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

