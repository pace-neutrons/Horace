classdef sqw_binfile_common < sqw_file_interface
    % Class contains common logic and code used to access binary sqw files
    %
    %  Binary sqw-file accessors inherit this class, use common method,
    %  defined in this class, implement remaining abstract methods,
    %  inherited from sqw_file_interface and overload the methods, which
    %  have different data access requests.
    %
    % sqw_file_interface Methods:
    % Implemented accessors:
    % get_main_header - obtain information stored in main header
    %
    % get_header      - obtain information stored in one of the
    %                   contributing file's header
    % get_detpar      - retrieve detectors information.
    % get_pix         - get pixels info
    % get_instrument  - get instrument information specific for a run
    % get_sample      - get sample information
    %
    % Implemented mutators:
    %
    % Common for all faccess_sqw_* classes:
    % put_main_header    - store main sqw file header.
    % put_headers        - store all contributing sqw file headers.
    % put_det_info       - store detectors information
    % put_pix            - store pixels information
    % put_sqw            - store whole sqw object, which involves all
    %                      put methods mentioned above
    %
    % extended, version specific interface:
    % put_instruments   -  store instruments information
    % put_samples       -  store sample's information
    %
    % upgrade_file_format - upgrade current sqw file to recent file format.
    %                       May change the sqw file and always opens it in
    %                       write or upgrade mode.
    
    %
    % $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties(Access=protected,Hidden=true)
        % position (in bytes from start of the file of the appropriate part
        % of Horace data information and the size of this part.
        % 0 means unknown/uninitialized or missing.
        main_header_pos_=26;
        main_head_pos_info_ =[];
        header_pos_=0;
        header_pos_info_ =[];
        detpar_pos_=0;
        detpar_pos_info_ =[];
        urange_pos_ = 0;
        %
        pix_pos_=  'undefined';
        %
        eof_pix_pos_=0;
        %
    end
    properties(Dependent)
        % the position of pixels information in the file. Used to organize
        % separate access to pixel data;
        pix_position
    end
    properties(Constant,Access=private,Hidden=true)
        % list of field names to save on hdd to be able to recover
        % all substantial parts of appropriate sqw file
        data_fields_to_save_ = {'num_contrib_files_','npixels_',...
            'main_header_pos_','main_head_pos_info_','header_pos_',...
            'header_pos_info_','detpar_pos_','detpar_pos_info_'};
        pixel_fields_to_save_ = {'urange_pos_',...
            'pix_pos_','eof_pix_pos_'};
    end
    %
    methods(Access = protected,Hidden=true)
        function obj=init_from_sqw_obj(obj,varargin)
            % initialize the structure of sqw file using sqw object as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            if nargin < 2
                error('SQW_FILE_IO:runtime_error',...
                    'init_from_sqw_obj method should be invoked with an existing sqw object as first input argument');
            end
            if ~(isa(varargin{1},'sqw') || is_sqw_struct(varargin{1}))
                error('SQW_FILE_IO:invalid_argument',...
                    'init_from_sqw_obj method should be initiated by an sqw object');
            end
            %
            obj = init_headers_from_sqw_(obj,varargin{1});
            % initialize data fields
            % assume max data type which will be reduced if some fields are
            % missing (how they when initialized from sqw?)
            obj.data_type_ = 'a'; % should it always be 'a'?
            obj = init_from_sqw_obj@dnd_binfile_common(obj,varargin{:});
            obj.sqw_holder_ = varargin{1};
            
            obj = init_pix_info_(obj);
        end
        %
        function obj=init_from_sqw_file(obj,varargin)
            % initialize the structure of faccess class using sqw file as input
            %
            % method should be overloaded or expanded by children if more
            % complex then common logic is used
            obj= init_sqw_structure_field_by_field_(obj);
        end
        %
        function [sub_obj,external] = extract_correct_subobj(obj,obj_name,varargin)
            % auxiliary function helping to extract correct subobject from
            % input or internal object
            [sub_obj,external]  = extract_correct_subobj_(obj,obj_name,varargin{:});
        end
        %
        function flds = fields_to_save(obj)
            % returns the fields to save in the structure in sqw binfile v3 format
            % sorted in the order of increase of the field location on hdd.
            %
            dnd_flds = fields_to_save@dnd_binfile_common(obj);
            flds = [obj.data_fields_to_save_(:);dnd_flds(:);...
                obj.pixel_fields_to_save_(:)];
        end
        
        function bl_map = const_blocks_map(obj)
            bl_map  = obj.const_block_map_;
        end
        %
        function [obj,missinig_fields] = copy_contents(obj,other_obj,keep_internals)
            % the main part of the copy constructor, copying the contents
            % of the one class into another.
            %
            % Copied of dnd_binfile_common to support overloading as
            % private properties are not accessible from parents
            %
            % keep_internals -- if true, do not overwrite service fields
            %                   not related to position information
            %
            if ~exist('keep_internals','var')
                keep_internals = false;
            end
            [obj,missinig_fields] = copy_contents_(obj,other_obj,keep_internals);
        end
        %
        function obj = init_v3_specific(obj)
            % Initialize position information specific for sqw v3.1 object.
            % Interface function here. Generic is not implemented and
            % actual implementation in faccess_sqw_v3
            error('SQW_FILE_IO:runtime_error',...
                'init_v3_specific: generic method is not implemented')
        end
        
    end % end protected
    %
    methods % defined by this class
        % ---------   File Accessors:
        % get main sqw header
        main_header = get_main_header(obj,varargin);
        % get header of one of contributed files
        [header,pos]   = get_header(obj,varargin);
        % Read the detector parameters from properly initialized binary file.
        det = get_detpar(obj);
        % read main sqw data  from properly initialized binary file.
        [sqw_data,obj] = get_data(obj,varargin);
        % read pixels information
        pix    = get_pix(obj,varargin);
        % retrieve the whole sqw object from properly initialized sqw file
        [sqw_obj,varargout] = get_sqw(obj,varargin);
        % retrieve dnd part of the sqw object
        [dnd_obj,varargout] = get_dnd(obj,varargin);
        % ---------   File Mutators:
        % save or replace main file header
        obj = put_main_header(obj,varargin);
        %
        obj = put_headers(obj,varargin);
        %
        obj = put_det_info(obj,varargin);
        %
        obj = put_pix(obj,varargin);
        % Save new or fully overwrite existing sqw file
        obj = put_sqw(obj,varargin);
        %
        function obj = put_instruments(obj,varargin)
            error('SQW_FILE_IO:runtime_error',...
                'put_instruments is not implemented for faccess_sqw %s',...
                obj.file_version);
        end
        %
        function obj = put_samples(obj,varargin)
            error('SQW_FILE_IO:runtime_error',...
                'put_samples is not implemented for faccess_sqw %s',...
                obj.file_version);
            
        end
        %
        function pix_pos = get.pix_position(obj)
            % the position of pixels information in the file. Used to organize
            % class independent binary access to pixel data;
            pix_pos = obj.pix_pos_;
        end
        %
        %
        % return structure, containing position of every data field in the
        % file (when object is initialized)
        function   pos_info = get_pos_info(obj)
            % return structure, containing position of every data field in the
            % file (when object is initialized) plus some auxiliary information
            % used to fully describe this file
            %
            fields2save = obj.fields_to_save();
            pos_info  = struct();
            for i=1:numel(fields2save)
                fld = fields2save{i};
                pos_info.(fld) = obj.(fld);
            end
        end
        %
        % ------- Interface stubs and helpers:
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
        function data_form = get_data_form(obj,varargin)
            % Return the structure of the data file header in the form
            % it is written on hdd.
            %
            % The structure depends on data type stored in the file
            % (see dnd_file_interface data_type method)
            %
            % Usage:
            %
            %
            % Fields in the full structure are:
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
            %   data.pix        Array containing data for eaxh pixel:
            %                  If npixtot=sum(npix), then pix(9,npixtot) contains:
            %                   u1      -|
            %                   u2       |  Coordinates of pixel in the projection axes
            %                   u3       |
            %                   u4      -|
            %                   irun        Run index in the header block from which pixel came
            %                   idet        Detector group number in the detector listing for the pixel
            %                   ien         Energy bin number for the pixel in the array in the (irun)th header
            %                   signal      Signal array
            %                   err         Error array (variance i.e. error bar squared)
            %
            data_form = get_data_form_(obj,varargin{:});
        end
    end
    %
    methods(Static,Hidden=true)
        %
        function header = get_main_header_form(varargin)
            % Return the structure of the main header in the form it
            % is written on hdd.
            %
            % Usage:
            % >>header = obj.get_main_header_form();
            % >>header = obj.get_main_header_form('-const');
            %
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            % Fields in file are:
            % --------------------------
            %   main_header.filename   Name of sqw file that is being read, excluding path
            %   main_header.filepath   Path to sqw file that is being read, including terminating file separator
            %   main_header.title      Title of sqw data structure
            %   main_header.nfiles     Number of spe files that contribute
            %
            % The value of the fields define the number of dimensions of
            % the data except strings, which defined by the string length
            header = get_main_header_form_(varargin{:});
        end
        %
        function header = get_header_form(varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            % Usage:
            % header = obj.get_header_form();
            % header = obj.get_header_form('-const');
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            % Fields in file are:
            % --------------------------
            %   header.filename     Name of sqw file excluding path
            %   header.filepath     Path to sqw file including terminating file separator
            %   header.efix         Fixed energy (ei or ef depending on emode)
            %   header.emode        Emode=1 direct geometry, =2 indirect geometry
            %   header.alatt        Lattice parameters (Angstroms)
            %   header.angdeg       Lattice angles (deg)
            %   header.cu           First vector defining scattering plane (r.l.u.)
            %   header.cv           Second vector defining scattering plane (r.l.u.)
            %   header.psi          Orientation angle (deg)
            %   header.omega        --|
            %   header.dpsi           |  Crystal misorientation description (deg)
            %   header.gl             |  (See notes elsewhere e.g. Tobyfit manual
            %   header.gs           --|
            %   header.en           Energy bin boundaries (meV) [column vector]
            %   header.uoffset      Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
            %   header.u_to_rlu     Matrix (4x4) of projection axes in hkle representation
            %                        u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
            %   header.ulen         Length of projection axes vectors in Ang^-1 or meV [row vector]
            %   header.ulabel       Labels of the projection axes [1x4 cell array of character strings]
            %
            header = get_header_form_(varargin{:});
        end
        %
        function detpar_form = get_detpar_form(varargin)
            % Return structure of the contributing file header in the form
            % it is written on hdd.
            % Usage:
            % header = obj.get_detpar_form();
            % header = obj.get_detpar_form('-const');
            %
            % Second option returns only the fields which do not change if
            % filename or title changes
            %
            %
            % Fields in the structure are:
            %
            % --------------------------
            %   det.filename    Name of file excluding path
            %   det.filepath    Path to file including terminating file separator
            %   det.group       Row vector of detector group number
            %   det.x2          Row vector of secondary flightpath (m)
            %   det.phi         Row vector of scattering angles (deg)
            %   det.azim        Row vector of azimuthal angles (deg)
            %                  (West bank=0 deg, North bank=90 deg etc.)
            %   det.width       Row vector of detector widths (m)
            %   det.height      Row vector of detector heights (m)
            %
            % one field of the file 'ndet' is written to the file but not
            % present in the structure, so has format: field_not_in_structure
            % group,x2,phi,azim,width and height array sizes are defined by
            % this structure size
            detpar_form = get_detpar_form_(varargin{:});
        end
        
    end
end
