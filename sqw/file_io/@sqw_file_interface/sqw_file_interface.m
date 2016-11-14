classdef sqw_file_interface < dnd_binfile_common
    % Class to describe interface to access sqw files.
    %
    %   Various accessors should inherit this class, implement the
    %   abstract methods mentioned here and define protected fields, common
    %   for all sqw-file accessors
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Access=protected)
        %
        num_contrib_files_= 'undefined'
        %
        npixels_ = 'undefined';
        %
        pix_pos_=  'undefined';
    end
    %
    properties(Dependent)
        % number of files, used to construct the file, class is initiated
        % with
        num_contrib_files;
        %
        % number of pixels, contributing into this file. Empty for dnd-type
        % files
        npixels
        % the position of pixels information in the file. Used to organize
        % separate access to pixel data;
        pix_position
    end
    %----------------------------------------------------------------------
    methods
        function nfiles = get.num_contrib_files(obj)
            % return number of run-files contributed into sqw object
            % provided
            nfiles = obj.num_contrib_files_;
        end
        %
        function npix = get.npixels(obj)
            npix = obj.npixels_;
        end
        function pix_pos = get.pix_position(obj)
            % the position of pixels information in the file. Used to organize
            % class independent access to pixel data;
            pix_pos = obj.pix_pos_;
        end
        %-------------------------
        function obj = delete(obj)
            % destructor, which is not fully functioning
            % operation for normal(non-handle) Matlab classes.
            % Usually needs the class on lhs of delete expression or
            % understanding when this can be omitted
            %
            obj.num_contrib_files_ = 'undefined';
            obj.npixels_ = 'undefined';
            obj = delete@dnd_binfile_common(obj);
            % its still sqw loader
            obj.sqw_type_ = true;
        end
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    methods(Abstract)
        % retrieve different parts of sqw data
        %main_header = get_main_header(obj,['-verbatim']);
        main_header = get_main_header(obj,varargin);
        %
        header      = get_header(obj,varargin);
        detpar      = get_detpar(obj,varargin);
        pix         = get_pix(obj,varargin);
        [inst,obj]  = get_instrument(obj,varargin);
        [samp,obj]  = get_sample(obj,varargin);
        
        % common write interface;
        obj = put_main_header(obj,varargin);
        obj = put_headers(obj,varargin);
        obj = put_det_info(obj,varargin);
        obj = put_pix(obj,varargin);
        obj = put_sqw(obj,varargin);
        % extended interface:
        obj = put_instruments(obj,varargin);
        obj = put_samples(obj,varargin);
        % upgrade current sqw file to recent file format. May change the
        % sqw file and always opens it in write mode.
        new_obj = upgrade_file_format(obj);
    end
    
end
