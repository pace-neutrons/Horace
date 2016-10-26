classdef dnd_binfile_common < dnd_file_interface
    % Class contains common logic and code used to access binary sqw files
    %
    %  Binary sqw-file accessors inherit this class, use common method,
    %  defined in this class implement remaining abstract methods,
    %  inherited from sqw_file_interface and overload the methods, which
    %  have different data access requests
    %
    %
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    %
    
    properties(Access=protected)
        file_id_=0 % the open file handle
        %
        % position (in bytes from start of the file of the appropriate part
        % of Horace data information and the size of this part.
        % 0 means unknown/uninitialized or missing.
        data_pos_=26;
        s_pos_=0;
        e_pos_=0;
        npix_pos_=0;
        urange_pos_=0;
        dnd_eof_pos_=0;
        %
        %
        sqw_serializer_=[];
        file_closer_ = [];
        % list of the sqw class fields or subclasses and auxiliary data
        % structures, stored on hdd
        %
        dnd_dimensions_ = 'undefined'
        data_type_ = 'undefined';
        app_header_form_ = struct('appname','horace','version',double(2),...
            'sqw_type',uint8(0),'ndim',0);
        
    end
    %
    properties(Dependent)
        % type of the data, stored in a file
        data_type
        % dimensions of the horace image (dnd object), stored in the file
        dnd_dimensions
        % the format of the application header stored by this class
        app_header_form;        
    end
    %
    methods(Access = protected)
        %
        function obj=init_from_sqw_obj(obj,varargin)
            % intialize the structure of sqw file using sqw object as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            obj = init_from_sqw_(obj,varargin{:});
        end
        %
        function obj=init_from_sqw_file(obj,varargin)
            % intialize the structure of faccess class using sqw file as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            obj= init_dnd_structure_field_by_field_(obj);
        end
    end
    
    methods % defined by this class
        % check if this loader should deal with selected file
        [ok,obj,mess]=should_load(obj,filename)
        %
        obj = check_file_upgrade_set_new_name(obj,new_filename,new_data_struct);
        %
        % read main dnd data  from propertly initialized binary file.
        %
        [dnd_data,obj] = get_data(obj,varargin);
        % read pixels information
        % retrieve the whole dnd object from properly initialized dnd file
        sqw_obj = get_sqw(obj,varargin);
        %
        
        function [inst,obj] = get_instrument(obj,varargin)
            % get instrument, stored in a file. If no instrument is
            % defined, return empty structure.
            inst = struct();
        end
        %
        function [samp,obj] = get_sample(obj,varargin)
            % get sample, stored in a file. If no sample is defined, return
            % empty structure.
            samp = struct();
        end
        %
        function [should,obj,mess]= should_load_stream(obj,stream,fid)
            % Check if this loader should deal with selected data stream
            %Usage:
            %
            %>> [should,obj] = obj.should_load_stream(datastream,fid)
            % structure returned by get_file_header function
            % Returns:
            % true if the loader can load these data, or false if not
            % with message explaining the reason for not loading the data
            % of should, object is initiated by appropriate file inentified
            mess = '';
            if isstruct(stream) && all(isfield(stream,{'sqw_type','version'}))
                if stream.sqw_type == obj.sqw_type && stream.version == obj.file_ver_
                    obj.file_id_ = fid;
                    obj.num_dim_ = double(stream.num_dim);
                    obj.file_closer_ = onCleanup(@()obj.close());
                    should = true;
                else
                    should = false;
                    if stream.sqw_type
                        type = 'sqw';
                    else
                        type = 'dnd';
                    end
                    mess = ['not Horace ',type,' ',obj.file_version,' file'];
                end
            else
                error('DND_FILE_INTERFACE:invalid_argument',...
                    'the input structure for should_load_stream function does not have correct format');
            end
        end        
        %
        function obj = init(obj,varargin)
            % Initialize sqw accessor using various input sources
            %
            %Usage:
            %>>obj=obj.init() -- initialize accessor from the object, which
            %                    has been already initialized from existing
            %                    sqw file and has its file opened by should_load
            %                    method.
            %                    should_load method should report ok, to confirm that
            %                    this loader can load sqw format version provided.
            
            %>>obj=obj.init(filename) -- initialize accessor to load  sqw file
            %                    with the filename provided.
            %                    The file should exist and the format of the
            %                    file should correspond to this loader
            %                    format.
            %>>obj=obj.init(sqw_object) -- prepare accessor to save
            %                    sqw object in appropriate binary format.
            %                    The file name to save the data should be set
            %                    separately.
            %>>obj=obj.init(sqw_object,filename) -- prepare accessor to save
            %                    sqw object in appropriate binary format.
            %                    Also the name of the file to save the data is
            %                    provided.
            %                    If the filename is the name of an exisiting file,
            %                    the file will be overwritten or upgraded if the loader
            %                    has alreadty been initiated with this file
            
            obj.sqw_serializer_ = sqw_serializer();
            obj = common_init_logic_(obj,varargin{:});
        end
        %
        function ff=get.data_type(obj)
            %   data_type   Type of sqw data written in the file
            %   type 'b'    fields: filename,...,dax,s,e
            %   type 'b+'   fields: filename,...,dax,s,e,npix
            %   type 'a'    fields: filename,...,dax,s,e,npix,urange,pix
            %   type 'a-'   fields: filename,...,dax,s,e,npix,urange
            ff = obj.data_type_;
        end
        %
        function dims = get.dnd_dimensions(obj)
            dims = obj.dnd_dimensions_;
        end
        %
        function close(obj)
            % Close existing file
            if obj.file_id_ >0
                fclose(obj.file_id_);
            end
            obj.file_id_ = -1;
            close@dnd_file_interface(obj);
        end
        %
        function data_form = get_data_form(obj,varargin)
            % Return the structure of the data file header in the form
            % it is written on hdd.
            % Fields in the structure are:
            %
            
            % ------------------------------
            %   data.filename   Name of sqw file that is being read, excluding path
            %   data.filepath   Path to sqw file that is being read, including terminating file separator
            %          [Note that the filename and filepath that are written to file are ignored; we fill with the
            %           values corresponding to the file that is being read.]
            %
            %   data.title      Title of sqw data structure
            %   data.alatt      Lattice parameters for data field (Ang^-1)
            %   data.angdeg     Lattice angles for data field (degrees)
            %   data.uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   data.u_to_rlu   Matrix (4x4) of projection axes in hkle representation
            %                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   data.ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   data.ulabel     Labels of the projection axes [1x4 cell array of character strings]
            %   data.iax        Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   data.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   data.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   data.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
            %   data.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
            %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
            %                  be reordered [row vector]
            %   data.s          Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.e          Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.npix       No. contributing pixels to each bin of the plot axes.
            %                  [size(data.pix)=(length(data.p1)-1, length(data.p2)-1, ...)]
            %   data.urange     True range of the data along each axis [urange(2,4)]
            %
            data_form = struct('filename','','filepath','',...
                'title','',...
                'alatt',single([1,3]),'angdeg',single([1,3]),...
                'uoffset',single([4,1]),'u_to_rlu',single([4,4]),...
                'ulen',single([1,4]),'ulabel',field_cellarray_of_strings(),...
                'npax',field_not_in_structure('pax'),...
                'iax',field_iax(),...
                'iint',field_iint(),...
                'pax',field_const_array_dependent('npax',1,'int32'),...
                'p_size',field_p_size(),...
                'p',field_cellarray_of_axis('npax'),...
                'dax',field_const_array_dependent('npax',1,'int32'));
            if nargin>1
                if strncmp(varargin{1},'-h',2) % header only
                    return
                end
            end
            data_form.s = field_img();
            data_form.e = field_img();
            data_form.npix = field_img('uint64');
            data_form.urange = single([2,4]);
            
            if strncmp(obj.data_type,'un',2); return; end
            
            if nargin>1
                % return full header
                if strncmp(varargin{1},'-f',2); return;  end
            end
            %
            if obj.data_type == 'b+' % data do not have pixels and ranges
                data_form = rmfield(data_form,'urange');
                return
            end
            if obj.data_type == 'b' % data do not have pixels, ranges and npix
                data_form = rmfield(data_form,{'urange','npix'});
                return
            end
        end
    end
    
end

