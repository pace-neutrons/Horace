classdef d3d < DnDBase
    %D3D Create an 2-dimensional DnD object
    %
    % Syntax:
    %   >> w = d3d()               % Create a default, empty, D3D object
    %   >> w = d3d(sqw)            % Create a D3D object from a 3-dimensional SQW object
    %   >> w = d3d(filename)       % Create a D3D object from a file
    %   >> w = d3d(struct)         % Create from a structure with valid fields (internal use)

    properties (Dependent,Access = protected)
        NUM_DIMS;
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class. Put it as it is replacing the
            obj = d3d();
            obj = loadobj@serializable(S,obj);
        end
    end

    methods
        dat = IX_dataset_3d(obj);
        wout = cut (varargin);

        function obj = d3d(varargin)
            obj = obj@DnDBase(varargin{:});
            if nargin == 0
                obj.axes.single_bin_defines_iax = [false,false,false,true];
                obj.axes.dax= [1,2,3];
                obj.s_ = 0;
                obj.e_ = 0;
                obj.npix_ = 0;
            end
        end
        function [nd,sz] = dimensions(obj)
            nd = 3;
            sz = obj.axes_.data_nbins;
        end
        % actual plotting interface:
        %------------------------------------------------------------------
        % PLOT:
        [figureHandle, axesHandle, plotHandle] = sliceomatic(w, varargin);
        [figureHandle, axesHandle, plotHandle] = sliceomatic_overview(w,varargin);
        function nd = get.NUM_DIMS(~)
            nd =3;
        end

    end
end
