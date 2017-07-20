classdef IX_dataset_2d < IX_data_2d
    methods(Static)
        function obj = loadobj(data)
            % function to support loading of previous versions of the class
            % from mat files on hdd
            if isa(data,'IX_dataset_2d')
                obj = data;
            else
                obj = IX_dataset_2d();
                obj = obj.init_from_structure(data);
            end
        end
    end
    
    
    methods
        %------------------------------------------------------------------
        function obj= IX_dataset_2d(varargin)
            obj = obj@IX_data_2d(varargin{:});
        end
        %------------------------------------------------------------------
    end
    
end
