classdef IX_dataset_1d_multifit2 < mfclass
        
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = IX_dataset_1d_multifit2 (varargin)
            % Construct superclass
            classname = 'IX_dataset_1d';
            if nargin>0 && all(cellfun(@(x)isa(x,classname),varargin))
                args=varargin;
            elseif nargin==0
                args = {};
            else
                error(['Data arguments must all be of the same class: ',classname])
            end
            obj@mfclass (args{:});
            
            % Set wrapper
            obj = set_wrapped_functions_ (obj, @func_eval, {}, @func_eval, {});
        end
        %------------------------------------------------------------------

    end
end
