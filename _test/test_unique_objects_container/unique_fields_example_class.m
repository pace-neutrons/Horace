classdef unique_fields_example_class
    %UNIQUE_FIELDS_EXAMPLE_CLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        myfield = []
        mydisc = []
    end
    
    methods
        function obj = unique_fields_example_class(disc,field)
            obj.myfield = field;
            obj.mydisc = disc;
        end
        
     end
end

