classdef faccess_sqw_v3_2 < faccess_sqw_v3
    % Class to access Horace binary files written in binary format v3.2
    % The format differs from 3.1 format as it used for
    % indirect instrument with range of efixed energies.
    %
    %
    % Usage:
    %1)
    %>>sqw_access = faccess_sqw_v3_2(filename)
    % or
    % 2)
    %>>sqw_access = faccess_sqw_v3_2(sqw_dnd_object,filename)
    %
    % 1)
    % First form initializes accessor to existing sqw file where
    % filename  :: the name of existing sqw file written
    %                     in sqw v3.2 format.
    %
    % Throws if file with filename is missing or is not written in
    % sqw v3.2 format.
    %
    % To avoid attempts to initialize this accessor using incorrect sqw file,
    % access to existing sqw files should be organized using sqw
    % formats factory namely:
    %
    % >>accessor = sqw_formats_factory.instance().get_loader(filename)
    %
    % If the sqw file with filename is sqw v3.1 sqw file, the sqw format
    % factory will return instance of this class, initialized for
    % reading this file.
    % The initialized object allows to use all get/read methods described
    % by sqw_file_interface,
    % dnd_file_interface and additional methods to read instrument and
    % sample, specific for v3.2 file format.
    %
    % 2)
    % Second form used to initialize the operation of writing new or
    % updating existing sqw file.
    % where:
    % sqw_dnd_object:: existing fully initialized sqw object in memory.
    % filename      :: the name of a new or existing sqw object on disc
    %
    % Update mode is initialized if the file with name filename exists and
    % can be updated, i.e. has the same number of dimensions, binning axis
    % and pixels.
    % In this case you can modify dnd or sqw metadata or explicitly
    % overwrite pixels.
    %
    % If existing file can not be updated, it will be open in write mode.
    % If file with filename does not exist, the object will be open in write mode.
    %
    % Initialized faccess_sqw_v3 object allows to use write/update methods of
    % dnd_file_interface, sqw_file_interface + writing instrument and sample
    % and all read methods of these interfaces if the proper information
    % already exists in the file.
    %
    %
    % $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
    %
    %
    
    %
    methods(Access=protected,Hidden=true)
    end
    %
    %
    methods
        %
        %
        function obj=faccess_sqw_v3_2(varargin)
            % constructor, to build sqw reader/writer version 3
            %
            % Usage:
            % ld = faccess_sqw_v3_2() % initialize empty sqw reader/writer
            %                        version 3.2
            %                       The class should be initialized later using
            %                       init command
            % ld = faccess_sqw_v3_2(filename) % initialize sqw reader/writer
            %                       version 3.2
            %                       to load sqw file version 3.
            %                       Throws error if the file version is not sqw
            %                       version 3.2
            % ld = faccess_sqw_v3_2(sqw_object) % initialize sqw
            %                       reader/writer version 3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            % ld = faccess_sqw_v3_2(sqw_object,filename) % initialize sqw
            %                       reader/writer version 3
            %                       to save sqw object provided. The name
            %                       of the file to save the object should
            %                       be provided separately.
            
            %
            % set up fields, which define appropriate file version
            obj = obj@faccess_sqw_v3(varargin{:});
            obj.file_ver_ = 3.2;
        end
        
        %
        function obj = upgrade_file_format(obj)
            % upgrade the file to recent write format and open this file
            % for writing/updating
            %
            % v3.2 is not upgradable recent file format, so
            % the method just reopens file for update.
            if ~isempty(obj.filename)
                obj = obj.set_file_to_update();
            end
        end
        %
    end
    methods(Static,Hidden=true)
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
            %   header.efix         Array of fixed energies for all crystal analysers
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
    end
    %
end

