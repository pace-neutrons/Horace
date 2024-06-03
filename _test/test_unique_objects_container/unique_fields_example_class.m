classdef unique_fields_example_class < serializable
    %UNIQUE_FIELDS_EXAMPLE_CLASS skeleton class to illustrate and test
    %   extraction of a property value by its field name
    
    properties
        myfield = []
        mydisc = []
    end
    
    methods
        function obj = unique_fields_example_class(disc,field)
            %UNIQUE_FIELDS_EXAMPLES_CLASS 
            % inputs:
            % - disc : a string to be displayed showing which object this is
            % - field : the object to be stored in property myfield
            obj.myfield = field;
            obj.mydisc = disc;
        end
        
        function ver = classVersion(~)
            ver = 0;
        end
        
        function flds = saveableFields(obj)
            flds = {'myfield','mydisc'};
        end
        
     end
end

