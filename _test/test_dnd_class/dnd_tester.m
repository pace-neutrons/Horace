classdef dnd_tester < DnDBase
    % Class for testing protected properties and methods of dnd objects
    properties(Access=protected)
        dnd_holder_;
    end

    methods
        function obj = dnd_tester(varargin)
            obj = obj@DnDBase();
            if nargin>0
                if isa(varargin{1},'DnDBase')
                    obj.dnd_holder_ = varargin{1};
                else
                    obj = obj.init(varargin{:});
                end
            end
        end
        function [proj,pbin] = get_proj_and_pbin_pub(obj)
            if isempty(obj.dnd_holder_)
                [proj,pbin] = obj.get_proj_and_pbin();
            else
                [proj,pbin] = obj.dnd_holder_.get_proj_and_pbin();
                pbin = pbin';
            end
        end
        function [nd,sz] = dimensions(obj)
            % just to allow to instantiate the class.
            % not currently used
            nd = 0;
            sz = obj.axes_.data_nbins;
        end

    end
    methods(Access=protected)
        function nd = get_NUM_DIMS(obj)
            nd =obj.axes_.dimensions();
        end

    end
end