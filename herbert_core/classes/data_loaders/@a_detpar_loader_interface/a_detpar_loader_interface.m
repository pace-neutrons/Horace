classdef a_detpar_loader_interface < serializable
    % Class describes interface used to obtain detector parameters
    %
    properties(Dependent)
        % number of detectors defined by the file, describing detector
        % information
        n_det_in_par
        % array of detector parameters
        det_par;
        % the variable which describes the name of par file which
        % contain detector information
        % in particular, about the detectors angular positions
        par_file_name;
    end

    properties(Access=protected)
        % storage field for a par file name
        par_file_name_ ='';
        % number of detectors, defined in the file, described by the par
        % file name
        n_det_in_par_=[];
        % storage field for detector information
        det_par_=[];
    end

    %----------------------------------------------------------------------
    methods(Abstract)
        % method loads par data into run data structure and returns
        % it in the format,requested by user
        [det,obj]=load_par(obj,varargin)

        % Data fields which are defined by a par file
        % ASCII Par or phx file defines det_par only (n_detectors in
        % the loader is dependent/service field) but other types of par
        % files can contain fields with additional information.
        fields = loader_define(this);

        % clear memory from loaded detectors information
        this=delete(this)

        % The data fields an par loader defines
        fields = par_can_define(obj);
    end
    %
    methods(Abstract,Access = protected)    
        % set the name (and redefine appropriate par loader) for the par file,
        % used as input for detector parameters
        obj = set_par_file_name(obj,par_f_name)
    end
    %
    methods(Static,Abstract)
        % get number of detectors defined by par,phx nxspe or other supported
        % file, and return other information, if it is requested
        [ndet,fh]=get_par_info(par_file_name)
    end
    methods
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR SPECIAL PROPERTIES     -----------------
        % -----------------------------------------------------------------
        function pfn = get.par_file_name(obj)
            pfn = get_par_file_name(obj);
        end
        function obj = set.par_file_name(obj,val)
            % Method sets this par file name as the source par file name.
            %
            % Depending on the current state, it can clear all previous
            % file information from memory
            obj = set_par_file_name(obj,val);
        end
        %
        function ndet = get.n_det_in_par(obj)
            ndet = get_n_det_in_par(obj);
        end
        %
        function det_par= get.det_par(obj)
            det_par = get_det_par(obj);
        end

        % connected properties related to det_par location in file or in
        % memory
        %
        function obj=set.det_par(obj,value)
            % method sets detector parameters from memory
            %Usage:
            %loader.det_par = value;
            %where value is 6-column array of detector's value correspondent to
            %the one, usually defined in par file but with opposite sign of azimuthal angle
            %or Horace structure with correspondent information
            %
            %if the value to set is syntactically correct, the operation sets
            %also n_detectors to the number of detectors, defined by the array
            obj = set_det_par(obj,value);
        end
        %
        function fields = get_par_defined(this)
            % method checks what fields in the structure are defined from the fields
            % the par file should define.
            fields = check_par_defined_(this);
        end
        % SERIALIZABLE INTERFACE
        function ver  = classVersion(~)
            ver= 1;
        end
        function flds = saveableFields(obj)
            call_stack = dbstack;
            for_saving = strncmp(call_stack(2).name,'to',2);

            if for_saving  % if conversion is to structure
                if isempty(obj.det_par_)          % export fields depending on
                    flds = {'par_file_name'};     % the state obj in memory
                else % order is important
                    flds = {'det_par','par_file_name'};
                end
            else % if conversion from structure, all fields are needed
                flds = {'det_par','par_file_name'};
            end
        end
    end
    methods(Access=protected)
        % over-loadable getters, provided to be replaced in a_loader
        % interface
        function  pfn = get_par_file_name(obj)
            pfn = obj.par_file_name_;
        end
        function det_par = get_det_par(obj)
            det_par = obj.det_par_;
        end
        function  ndet = get_n_det_in_par(obj)
            ndet = obj.n_det_in_par_;
        end
        %
        function [return_array,force_reload,getphx,lext,filename]=parse_loadpar_arguments(obj,varargin)
            % Auxiliary method processes the arguments specified with load_par methods
            %
            % usage:
            %>>this = load_par(this,'-nohor')
            %                      returns detectors information loaded from the nxspe file,
            %                      previously associated with loader_nxspe class by
            %                      loader_nxspe constructor
            %  this             -- the instance of properly initiated loader class
            %
            % '-nohor' or '-array' -- if present request to return the data as
            %                      as (6,ndet) array with fields:

            %     1st column    sample-detector distance
            %     2nd  "        scattering angle (deg)
            %     3rd  "        azimuthal angle (deg)
            %                   (west bank = 0 deg, north bank = -90 deg etc.)
            %                   (Note the reversed sign convention cf .phx files)
            %     4th  "        width (m)
            %     5th  "        height (m)
            %     6th  "        detector ID
            % it return it as Horace structure otherwise

            % '-forcereload'    -- load_par command does not reload
            %                    detector information if the full file name
            %                    (with path)
            %                    stored in the Horace detector structure
            %                    coincides with par_file_name defined in
            %                    the class. Include this option if one
            %                    wants to reload this information at each
            %                    load_par.
            %
            %>>[det,this]=load_par(this,file_name,['-nohor'])
            %                     returns detectors information from the file
            %                     name specified. The function also redefines
            %                     the file name, stored in the loader
            %
            [return_array,force_reload,getphx,lext,filename]=parse_loadpar_arguments_(obj,varargin{:});
        end
        %
        function  [det_par,n_det_in_par,par_file_name] = check_det_par(obj,value)
            % method checks if value can represent par file and detectors coordinates
            % and converts this value into format, used in det_par field
            %
            [det_par,n_det_in_par,par_file_name] = check_det_par_(obj,value);
        end
        function obj=set_det_par(obj,value)
            % method sets detector parameters from memory
            %Usage:
            %loader.det_par = value;
            %where value is 6-column array of detector's value correspondent to
            %the one, usually defined in par file but with opposite sign of azimuthal angle
            %or Horace structure with correspondent information
            %
            %if the value to set is syntactically correct, the operation sets
            %also n_det_in_par to the number of detectors, defined by the array
            %
            if isempty(value)
                obj=obj.delete();
                return
            end
            [obj.det_par_,obj.n_det_in_par_,obj.par_file_name_] = obj.check_det_par(value);
        end
        %
    end
    %
    methods(Static,Access=protected)
        function phx = convert_par2phx(par)
            % internal function changing data format from par to phx
            %
            % par contains col:
            %     4th  "        width (m)
            %     5th  "        height (m)
            %phx contains col:
            %    4 	angular width e.g. delta scattered angle (deg)
            %    5 	angular height e.g. delta azimuthal angle (deg)

            phx = par;
            phx(4,:) =(360/pi)*atan(0.5*(par(4,:)./par(1,:)));
            phx(5,:) =(360/pi)*atan(0.5*(par(5,:)./par(1,:)));
        end
        function par = convert_phx2par(phx)
            % internal function changing data format from phx to par
            %phx contains col:
            %    4 	angular width e.g. delta scattered angle (deg)
            %    5 	angular height e.g. delta azimuthal angle (deg)
            % par contains col:
            %     4th  "        width (m)
            %     5th  "        height (m)

            par = phx;
            par(4,:) =2*(phx(1,:).*tand(0.5*phx(4,:)));
            par(5,:) =2*(phx(1,:).*tand(0.5*phx(5,:)));
        end
        %
        function [ndet,nxspe_version,nexus_dir,NXspeInfo,f_name]=get_nxspe_file_info(file_name)
            % get number of detectors and the structure of nexus file describing nxspe file
            % Input:
            %  par_file_name -- the name of the nxspe file, containing the
            %                   detector information
            % Output:
            %  ndet  -- number of detectors defined in the input file
            %  nxspe_version -- version of nxspe file. (Defined by Mantid)
            %  nexus_dir     -- root directory of the whole nxspe dataset
            %  NXspeInfo     -- the structure, containing internal layout
            %                   of the nxspe data file
            if ~ischar(file_name)
                error('HERBERT:a_detpar_loader:invalid_argument',...
                    ' first parameter has to be a file name');
            end

            [ok,mess,f_name] = check_file_exist(file_name,{'.nxspe'});
            if ~ok
                error('HERBERT:a_detpar_loader:invalid_argument',mess);
            end
            if ~H5F.is_hdf5(f_name)
                error('HERBERT:a_detpar_loader:invalid_argument',...
                    'file %s is not proper hdf5 file',file_name);
            end

            [nexus_dir,nxspe_version,nexus_file_structure] = find_root_nexus_dir(f_name,'NXSPE');
            if isempty(nexus_dir)
                error('HERBERT:a_detpar_loader:invalid_argument',...
                    'NXSPE data can not be located within nexus file: %s',...
                    file_name);
            end
            NXspeInfo   =find_dataset_info(nexus_file_structure,nexus_dir,'');
            NXspeInfo.Filename = nexus_file_structure.Filename;
            dataset_info=find_dataset_info(NXspeInfo,'data','data');
            ndet    = dataset_info.Dataspace.Size(2);

        end

    end
end