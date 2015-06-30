classdef aprojection
    %  Abstract class, defining interface using by cut_sqw
    %  when transforming pixels from original to cut's coordinate system
    %
    % Also defines generic operations on sqw object, which may be useful
    % for any projection classes.
    properties(Dependent)
        % is special mex routines, written for performance reason and as such
        % deeply embedded with cut_sqw objects  are availible for given
        % projection type
        can_mex_cut; %false
        % can projection retain pixels so that further cuts can be made
        % from the results of projection. E.g. one can make subsequent cuts
        % from a
        can_keep_pixels; %false;
    end
    
    methods
        function proj=aprojection(varargin)
        end
        
        function can_mex_cut = get.can_mex_cut(self)
            % generic projection can not run mex code
            can_mex_cut  = can_mex_cut_(self);
        end
        function can_retain_pixels = get.can_keep_pixels(self)
            % generic projection can not apply one cut after another, so
            % keeping pixels is prohibited by default
            can_retain_pixels = can_keep_pixels_(self);
        end
    end
    methods(Access = protected)
        function isit= can_mex_cut_(self)
            isit = false;
        end
        function isit= can_keep_pixels_(self)
            isit = false;
        end        
    end
    methods(Abstract)
        this=define_tranformation(this,data);
        % Retrieve all parameters, necessary to define a transformation
        % from sqw data
        this = set_proj_ranges(this,ustep,urange_step,urange_offset);
        % urange_step -- number of bin in every cut direction
        % ustep -- step size in each cut direction
        urange_out = find_bounding_box(this,urange_in);
        % find the whole range of input data which may contribute
        % into the result.
        % urange_in -- the range of the data in initial coordinate
        % system.
        [nbinstart,nbinend] = get_bin_range(this,urange,nelmts,varargin);
        % Get range of grid bin indexes, which may contribute into the final
        % cut.
        %
        [indx,ok] = get_contributing_pix_ind(this,v);
        % get list of indexes contributing into the cut
        [uoffset,ulabel,dax,u_to_rlu,ulen] = get_proj_param(this,data_in,pax);
        % get projection parameters, necessary for properly definind a sqw or dnd object
        %
    end
end
