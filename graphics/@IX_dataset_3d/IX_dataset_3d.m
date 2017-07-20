classdef IX_dataset_3d < IX_data_3d
    methods(Static)
        function obj = loadobj(data)
            % function to support loading of previous versions of the class
            % from mat files on hdd
            if isa(data,'IX_dataset_3d')
                obj = data;
            else
                obj = IX_dataset_3d();
                obj = obj.init_from_structure(data);
            end
        end
    end
    
    
    methods
        %------------------------------------------------------------------
        function obj= IX_dataset_3d(varargin)
            obj = obj@IX_data_3d(varargin{:});
        end
        %------------------------------------------------------------------
    end
    
end
