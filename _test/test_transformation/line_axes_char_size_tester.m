classdef line_axes_char_size_tester< line_axes
    % Helper class which tests get_char_size method for line_proj and its
    %   Detailed explanation goes here

    properties
        use_generic = false;
    end

    methods
        function obj = line_axes_char_size_tester(varargin)
            obj = obj@line_axes();
            if nargin == 0
                return;
            end
            if nargin == 1 && isa(varargin{1},'line_axes')
                in = varargin{1}.to_struct();
                obj = obj.from_struct(in,obj);
            else
                obj = obj.init(varargin{:});                
            end

        end

        function sz = get_char_size(obj,proj)
            if obj.use_generic
                sz = get_char_size@AxesBlockBase(obj,proj);
            else
                sz = get_char_size@line_axes(obj,proj);
            end
        end
    end
end