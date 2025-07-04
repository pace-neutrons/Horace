classdef d4d < DnDBase
    %D4D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d4d()               % Create a default, empty, D4D object
    %   >> w = d4d(sqw)            % Create a D4D object from a 4-dimensional SQW object
    %   >> w = d4d(filename)       % Create a D4D object from a file
    %   >> w = d4d(struct)         % Create from a structure with valid fields (internal use)
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d4d();
            obj = loadobj@serializable(S,obj);
        end
    end
    methods(Access=protected)
        function  nd = get_NUM_DIMS(~)
            % NUM_DIMS getter. Return number of object dimensions
            nd =4;
        end
    end
    methods
        function obj = d4d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin == 0
                obj.do_check_combo_arg = false;
                obj.axes.single_bin_defines_iax = [false,false,false,false];
                obj.axes.dax= [1,2,3,4];
                obj.s_ = 0;
                obj.e_ = 0;
                obj.npix_ = 0;
                obj.do_check_combo_arg = true;
            end

        end
        function [nd,sz] = dimensions(obj)
            nd = 4;
            sz = obj.axes_.data_nbins;
        end
    end
end
