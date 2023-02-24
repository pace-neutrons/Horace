classdef an_axis_caption < serializable
    %Lightweight class -- parent for different various axis caption classes
    %
    % By default implements sqw rectangular cut captions
    %
    properties(Dependent)
    end

    methods
        function obj=an_axis_caption(varargin)
            obj.caption_calc_func_ = @data_plot_titles;
        end
    end
    %======================================================================
    % SERIALIZABLE INTERFACE
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = an_axis_caption();
            obj = loadobj@serializable(S,obj);
        end
    end
    %----------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw/sqw data format. Each new version would presumably
            % read the older version, so version substitution is based on
            % this number
            ver = 1;
        end
        %
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = {};
        end
    end
end


