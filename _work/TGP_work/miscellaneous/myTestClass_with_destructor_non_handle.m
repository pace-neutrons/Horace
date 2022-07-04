classdef myTestClass
    properties
        nog=[];
    end
    properties (Hidden)
        cleanup
    end
    methods ( Access = 'public' )
        function obj = myTestClass(nog)
            obj.nog = nog;
            obj.cleanup = onCleanup(@()delete(obj));
        end
    end
    methods ( Access = 'private' )
        %# I suggest hiding the delete method, since it does not
        %# actually delete anything
        function obj = delete( obj )
            disp('deleting...')
        end
    end % public methods
end
