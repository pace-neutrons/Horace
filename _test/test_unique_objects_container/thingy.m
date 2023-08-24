classdef thingy
    %THINGY Simple class with public property data
    %   Used for demonstrating ability of unique_objects_container to set a
    %   property of one of its subscripted items.
    
    properties
        data
    end
    
    methods
        function obj = thingy(d)
            %THINGY Construct an instance of this class
            %   A thingy has its property data set
            obj.data = d;
        end
    end
    
    methods (Static)
        function demo()
            %DEMO makes a unique_objects_container of thingies
            % adds the first element of data==1
            % resets the first element so data==9
            uoc = unique_objects_container('thingy');
            th = thingy(1);
            uoc{1} = th;
            disp(uoc{1});
            uoc{1}.data = 9;
            disp(uoc{1});
        end
    end
end

