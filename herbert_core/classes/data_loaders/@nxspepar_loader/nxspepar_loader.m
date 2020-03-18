classdef nxspepar_loader < a_detpar_loader_interface
    % The class responsible for loading ascii par and phx files
    %
    %Defines methods used to load detector parameters from ASCI par or phx file
    %when the main data file does not contain detector information or
    %detector parameters have to be redefined form an ASCII par file.
    %
    % If the main data file contains detector information, child loader
    % should
    % overload methods responsible for loading detector's information to work
    % both with ASCII par files and the detector information containing in
    % the main data file (if the later intended to be used)
    %
    % $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
    %
    %
    properties (Access=protected)
        % number of detectors, defined in the file, described by the par
        % file name
        n_detinpar_=[];
        % storage field for detector information
        det_par_=[];
        % storage field for a par file name
        par_file_name_ ='';
        % The data fields an nxspe par loader defines
        par_can_define_ = {'det_par','n_det_in_par'};
    end
    
    properties(Access=private)
        % the hdf folder, containing whole nxspe dataset
        nexus_root_dir_ = '';
        % the structure, containing the folder structure of the nxspe file
        % as defined in hdf5 file
        nexus_datast_info_ = [];
        % version of nxspe data
        nxspe_version_ = 0;
    end
    %
    methods
        % constructor;
        function this=nxspepar_loader(varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=nxspepar_loader();
            %   constructor, which specifies par file name:
            %>>this=nxspepar_loader(par_file_name);
            %   copy constructor:
            %>>this=nxspepar_loader(other_loader);
            %
            if nargin>0
                if ischar(varargin{1})
                    this.par_file_name = varargin{1};
                elseif isa(varargin{1},'nxspepar_loader')
                    this=varargin{1};
                else
                    error('NXSPE_LOADER:invalid_argument',...
                        'nxspepar_loader constructor argument can be only nxspe file name or open file handler or other loader')
                end
            else
            end
        end
        %
        function [det,obj]=load_par(obj,varargin)
            % method loads par data into run data structure and returns it in the format,requested by user
            % if requested
            %
            % If the particular loader supposed to download its own detector information, this function should be overloaded
            % to access those information and to do arbitration what detector information should be used
            %
            % usage:
            %>>[det,this] = load_par(this,['-nohor'],['-force'],'-getphx')
            %                      returns detectors information loaded from the file,
            %                      previously associated with a class by
            %                      the class constructor
            %  det              -- detector's information in the form of
            %                      the Horace structure
            %  this             -- the instance of properly initiated loader class
            %  '-forcereload'     usually data are loaded in memory onece, and taken from memory after that
            %                     -forcereload request always loading data into memory.
            
            %
            % '-nohor' or '-array' -- if present request to return the data as
            %                      as (6,ndet) array with the data:
            %     1st column    sample-detector distance
            %     2nd  "        scattering angle (deg)
            %     3rd  "        azimuthal angle (deg)
            %                   (west bank = 0 deg, north bank = -90 deg etc.)
            %                   (Note the reversed sign convention cf .phx files)
            %     4th  "        width (m)
            %     5th  "        height (m)
            %     6th  "        detector ID
            %  otherwise, data will be returned as horace structure,
            %  defined below.
            %
            % '-forcereload'    -- load_par command does not reload
            %                     detector information if the full file name
            %                     (with path)
            %                     stored in the Horace detector structure
            %                     coincides with par_file_name defined in
            %                     the class. Include this option if one
            %                     wants to reload this information at each
            %                     load_par.
            %
            %>>[det,this]=load_par(this,file_name,['-nohor'],['-forcereload'],['-getphx'])
            %                     returns detectors information from the
            %                     par or phx file name specified.
            %                     The function also redefines
            %                     the file name, stored in the loader
            %
            %
            % the Horace structure has a form:
            %   det.filename    Name of file excluding path
            %   det.filepath    Path to file including terminating file separator
            %   det.group       Row vector of detector group number
            %   det.x2          Secondary flightpath (m)
            %   det.phi         Row vector of scattering angles (deg)
            %   det.azim        Row vector of azimuthal angles (deg)
            %                  (West bank=0 deg, North bank=90 deg etc.)
            %   det.width       Row vector of detector widths (m)
            %   det.height      Row vector of detector heights (m)
            %
            % '-getphx'         option returns data in phx format.
            %                   invoking this assumes (and sets up) -nohorace
            %                   option.
            % Phx data format has a form:
            %
            % 1st (1)	secondary flightpath,e.g. sample to detector distance (m)
            % 2nd (-)   0
            % 3rd (2)	scattering angle (deg)
            % 4th (3)	azimuthal angle (deg) (west bank = 0 deg, north bank = 90 deg etc.)
            %           Note the reversed sign convention wrt the .par files. For details, see: SavePAR v
            % 5th (4) 	angular width e.g. delta scattered angle (deg)
            % 6th (5)	angular height e.g. delta azimuthal angle (deg)
            % 7th (6)	detector ID. -- the number, defining a detector.
            %           This is Mantid specific value,
            %           which may not hold similar meaning in files written
            %           by different applications.
            %
            % In standard phx file only the columns 3,4,5 and 6 contain useful information.
            % You can expect to find column 1 to be the secondary flight-path and the column
            % 7 is the detector ID in Mantid-generated phx files only or in
            % the files read from nxspe source
            %
            % reader ignores column 2, so -getphx option returns array of
            % 6xndet data in similar to par format, but the meaning or the
            % columns 4 and 5 are different
            %
            [return_array,force_reload,getphx,~,filename] = parse_loadpar_arguments(obj,varargin{:});
            if ~isempty(filename)
                obj.par_file_name = filename;
            end
            [det,obj] = load_nxspe_par_(obj,return_array,force_reload,getphx);
            
        end
        %
        function fields = loader_define(this)
            % Data fields which are defined by a par file
            % ASCII Par or phx file defines det_par only (n_detectors in
            % the loader is dependent/service field) but other future par
            % files can contain fields with additional information.
            % For such loader this method should be overloaded
            
            %usage:
            %>> fields= loader_can_define(loader);
            %   loader -- the specific loader constructor
            %
            fields = get_par_defined(this);
        end
        %
        function fields = par_can_define(obj)
            fields = obj.par_can_define_;
        end
        
        %
        function this=delete(this)
            % clear memory from loaded detectors information
            this.det_par_=[];
            if isempty(this.par_file_name)
                this.n_detinpar_=[];
            end
        end
        %-----------------------------------------------------------------
        % NXSPE specific methods
        %-----------------------------------------------------------------
        function [nexus_dir,nexus_info,nxspe_ver] = get_nxspe_info(obj)
            % return information, retrieved from existing nxspe data file
            %
            % used to simplify joint operation of nxspepar_loader and
            % nxspe_loader
            %
            nexus_dir = obj.nexus_root_dir_;
            nexus_info= obj.nexus_datast_info_;
            nxspe_ver = obj.nxspe_version_;
        end
        %
        function [obj] = set_nxspe_info(obj,nexus_dir,nexus_info,nxspe_ver)
            % sets information, retrieved from existing nxspe data file
            %
            % used to simplify joint operation of nxspepar_loader and
            % nxspe_loader
            %
            obj.nexus_root_dir_= nexus_dir;
            obj.nexus_datast_info_= nexus_info;
            obj.nxspe_version_= nxspe_ver;
            if ~strcmp(obj.par_file_name_,nexus_info.Filename)
                obj = set_par_file_name(obj,nexus_info.Filename);
            end
        end
        % ------------------------------------------------------------------
    end
    %
    methods(Access=protected)
        %
        function obj=set_par_file_name(obj,par_f_name)
            % method checks if the ASCII file with the name par_file_name exists
            %
            % Then it sets this par file name as the source par file name and
            % clears all previous loaded par file information (if any).
            %
            if isempty(par_f_name)
                % disconnect detector information in memory from a par file
                obj.par_file_name_='';
                if isempty(obj.det_par)
                    obj.n_detinpar_=[];
                end
            else
                [ok,mess,f_name] = check_file_exist(par_f_name,{'.nxspe'});
                if ~ok
                    error('NXSPEPAR_LOADER:set_par_file_name',mess);
                end
                if ~strcmp(obj.par_file_name_,f_name)
                    obj.par_file_name_= f_name;
                    [obj.n_detinpar_,obj.nxspe_version_,...
                        obj.nexus_root_dir_,obj.nexus_datast_info_]...
                        = nxspepar_loader.get_par_info(f_name);
                    obj.det_par_=[];
                end
            end
            %
        end
        %
        %
        function fn = get_par_file_name(obj)
            fn  = obj.par_file_name_;
        end
        %
        function ndet = get_n_det_in_par(obj)
            ndet = obj.n_detinpar_;
        end
        %
        function det_par= get_det_par(obj)
            det_par = obj.det_par_;
        end
        %
        function obj=set_det_par(obj,value)
            % method sets detector parameters from memory
            %Usage:
            %loader.det_par = value;
            %where value is 6-column array of detector's value correspondent to
            %the one, usually defined in par file but with opposite sign of azimuthal angle
            %or Horace structure with correspondent information
            %
            %if the value to set is syntactically correct, the operation sets
            %also n_detectors to the number of detectors, defined by the array
            if isempty(value)
                obj=obj.delete();
                return
            end
            [obj.det_par_,obj.n_detinpar_,obj.par_file_name_] = obj.check_det_par(value);
        end
    end
    
    %
    methods(Static)
        
        function [ndet,nxspe_version,nexus_dir,NXspeInfo]=get_par_info(par_file_name)
            % get number of detectors and the structure of nexus file described in nxspe file
            % Input:
            %  par_file_name -- the name of the nxspe file, containing the
            %                   detector information
            % Output:
            %  ndet  -- number of detectors defined in the input file
            %  nxspe_version -- version of nxspe file. (Defined by Mantid)
            %  nexus_dir     -- root directory of the whole nxspe dataset
            %  NXspeInfo     -- the structure, containing internal layout
            %                   of the nxspe data file
            
            [ok,mess,f_name] = check_file_exist(par_file_name,{'.nxspe'});
            if ~ok
                error('NXSPEPAR_LOADER:invalid_argument',mess);
            end
            
            [nexus_dir,nxspe_version,nexus_file_structure] = find_root_nexus_dir(f_name,'NXSPE');
            if isempty(nexus_dir)
                error('NXSPEPAR_LOADER:invalid_argument','NXSPE data can not be located withing nexus file file %s\n',...
                    par_file_name);
            end
            NXspeInfo   =find_dataset_info(nexus_file_structure,nexus_dir,'');
            dataset_info=find_dataset_info(NXspeInfo,'data','data');
            ndet    = dataset_info.Dims(2);
        end
    end
end
