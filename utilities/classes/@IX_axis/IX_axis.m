classdef IX_axis
    %  IX_axis object contains the elements below.
    %  The elements can be set from constructor and also
    %  accessed/modified from the object properties:
    %
    % 	caption		char        Caption for axis
    %            or cellstr    (Caption can be multiline input in the form of a
    %                           cell array or a character array)
    %   units       char        Units for axis e.g. 'meV'
    %   code        char        Code for units (see documentation for built-in units;
    %                           can also be user-defined unit code)
    %
    %   vals        numeric     Array of tick positions
    %   labels      char        Character array or cellstr of tick labels
    %               or cellstr
    %   ticks       structure   Tick information with two fields
    %                               positions    tick positions (numeric array)
    %                               labels       cell array of tick labels
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties(Dependent)
        caption
        units
        code         % Not properly implemented?
        ticks
    end
    properties(Access=protected)
        caption_ = {};
        units_ = '';
        code_ = '';
        ticks_ = struct('positions',[],'labels',{{}});
    end
    methods(Static)
       function obj = loadobj(data)
            % function to support loading of outdated versions of the class
            % from mat files on hdd
            if isa(data,'IX_axis')
                obj = data;
            else
                obj = IX_axis();
                obj = obj.init_from_structure(data);
            end
        end    end
    methods
        function axis = IX_axis(varargin)
            % Create IX_axis object
            %   >> w = IX_axis (caption)
            %   >> w = IX_axis (caption, units)
            %   >> w = IX_axis (code)           % set cation and units via a standard units code
            %   >> w = IX_axis (...,code)       % override caption and/or units from the defined code
            %
            % Setting custom tick positions and labels
            %   >> w = IX_axis (...,vals)           % positions
            %   >> w = IX_axis (...,vals,labels)    % positions and labels
            %   >> w = IX_axis (...,ticks)          % strucutre with position and tick labels
            %
            if nargin > 0
                axis = buildIX_axis_(axis,varargin{:});
            end
        end
        % init object or array of objects from a structure with appropriate
        % fields
        obj = init_from_structure(axis,in)
        %------------------------------------------------------------------
        function cap = get.caption(obj)
            cap = obj.caption_;
        end
        function obj = set.caption(obj,cap)
            obj = check_and_set_caption_(obj,cap);
        end
        %
        function un = get.units(obj)
            un = obj.units_;
        end
        function obj = set.units(obj,un)
            obj = check_and_set_units_(obj,un);
        end
        %
        function un = get.code(obj)
            % Not properly implemented?
            un = obj.code_;
        end
        function obj = set.code(obj,code)
            % Not properly implemented?
            obj = check_and_set_code_(obj,code);
        end
        %
        function un = get.ticks(obj)
            un = obj.ticks_;
        end
        function obj = set.ticks(obj,ticks)
            % ticks should be a structure with fields 'positions' and
            % 'labels', containing array of ticks and cellarray of labels
            % correspondingly.
            %
            % TODO: easy to modify to set these values separately, without
            % combining them into a structure.
            obj = check_and_set_ticks_(obj,ticks);
        end
        %------------------------------------------------------------------
    end
end