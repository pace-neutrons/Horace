classdef thingy_tester < hashable
    %THINGY Simple class with public property data
    %   Used for demonstrating ability of unique_objects_container to set a
    %   property of one of its subscripted items.
    %   now subclassed from serializable to prevent large numbers of
    %   warnings when it is serialized via the global serializable function

    properties
        data
    end

    methods
        function obj = thingy_tester(d)
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
            uoc = unique_objects_container('thingy_tester');
            th = thingy(1);
            uoc{1} = th;
            disp(uoc{1});
            uoc{1}.data = 9;
            disp(uoc{1});
        end
    end

    methods % serializable

        function ver = classVersion(~)
            ver = 1;
        end

        function flds = saveableFields(~)
            flds = {'data'};
        end
    end
end

