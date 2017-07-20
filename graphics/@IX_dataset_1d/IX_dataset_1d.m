classdef IX_dataset_1d < IX_data_1d
    % Class adds operations with graphics to main operations with 1-d data
    %
    % See IX_data_1d for main properties and constructors, used to operate 
    % with 1d data 
    %
    methods(Static)
        function obj = loadobj(data)
            % function to support loading of outdated versions of the class
            % from mat files on hdd
            if isa(data,'IX_dataset_1d')
                obj = data;
            else
                obj = IX_dataset_1d();
                obj = obj.init_from_structure(data);
            end
        end
    end
    
    
    methods
        %------------------------------------------------------------------
        function obj= IX_dataset_1d(varargin)
            obj = obj@IX_data_1d(varargin{:});
        end
        %------------------------------------------------------------------
    end
    
end
