classdef asciipar_loader
    % The class responsible for loading ascii par and phx files
    %
    %Defines methods used to load detector parameters from ASCI par or phx file
    %or when the main data file does not contain detector information or
    %detector parameters have to be redefined form ASCII par file.
    %
    % If the main data file contains detector information, child loader
    % should
    % overload methods responsible for loading detector's information to work
    % both with ASCII par files and the detector information containing in
    % the main data file (if the later intended to be used)
    %
    % $Revision$ ($Date$)
    %
    % the properties common for all data loaders.
    properties(Dependent)
        % array of detector parameters
        det_par   =[];
        % the variable which describes the name of ASCII par file which, if present
        % contain detector information overwriting existing or providing
        % missing information about the detectors angular positions
        par_file_name='';
        % number of detectors, defined in the file, described by the par
        % file name
        %n_detectors=[];
        
    end
    properties (Access=protected)
        % helper properties used in set/get number of detectors
        n_detinpar_stor=[];
        det_par_stor=[];
        par_file_name_stor ='';
    end
    %
    methods
        % constructor;
        function this=asciipar_loader(varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=asciipar_loader();
            %   constructor, which specifies par file name:
            %>>this=asciipar_loader(par_file_name);
            %   copy constructor:
            %>>this=asciipar_loader(other_loader);
            %
            if nargin>0
                if isstring(varargin{1})
                    this.par_file_name = varargin{1};
                elseif isa(varargin{1},'asciipar_loader')
                    this=varargin{1};
                else
                    error('ASCIIPAR_LOADER:invalid_argument','asciipar_loader constructor argument can be only par file name or other loader')
                end
            else
            end
        end
        function [det,this]=load_par(this,varargin)
            % method loads par data into run data structure and returns it in the format,requested by user
            % if requsted
            %
            % this function has to have its eqivalents in all other loader classes
            % as all loaders are accessed through common interface.
            %
            % usage:
            %>>[det,this] = load_par(this,['-nohor'],['-force'])
            %                      returns detectors information loaded from the nxspe file,
            %                      previously associated with loader_nxspe class by
            %                      loader_nxspe constructor
            %  det              -- detector's information in the form of
            %                      the Horace structure
            %  this             -- the instance of properly initated loader class
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
            %                    detector information if the full file name
            %                    (with path)
            %                    stored in the horace detector structure
            %                    coinsides with par_file_name defined in
            %                    the class. Include this option if one
            %                    wants to reload this information at each
            %                    load_par.
            %
            %>>[det,this]=load_par(this,file_name,['-nohor'],['-forcereload'])
            %                     returns detectors information from the
            %                     par or phx file name specified.
            %                     The function alse redefines
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
            
            options = {'-nohorace','-array','-horace','-forcereload'};
            [return_array,force_reload,lext,this] = parse_loadpar_arguments(this,options,varargin{:});
            [det,this] = load_phx_or_par_private(this,return_array,force_reload,lext);
            
        end
        %
        function this=delete_par(this)
            % clear memory from loaded detectors information
            this.det_par_stor=[];
            if isempty(this.par_file_name)
                this.n_detinpar_stor=[];
            end
        end
        function fields = par_file_defines(this)
            % Data fields which are defined by a par file
            % ASCII Par or phx file defines det_par only (n_detectors in
            % the loader is dependent/service field) but other future par
            % files can contain fields with additional information.
            % For such loader this method should be overloaded
            
            %usage:
            %>> fields= par_file_defines(loader);
            %   loader -- the specific loader constructor
            %
            fields = check_par_defined(this);
        end
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR SPECIAL PROPERTIES     -----------------
        % -----------------------------------------------------------------
        % connected properties related to det_par location in file or in
        % memory
        function det_par=get.det_par(this)
            % get method for dependent property det_par
            det_par= this.det_par_stor;
        end
        function this=set.det_par(this,value)
            % method sets detector parameters from memory
            %Usage:
            %loader.det_par = value;
            %where value is 6-column array of detector's value correspondent to
            %the one, usually defined im par file but with opposite sign of azimuthal angle
            %or horace structure with correspondant information
            %
            %if the value to set is syntaxially correct, the operation sets
            %also n_detectors to the number of detectors, defined by the array
            % If the par_file_name is present, this operation also clears
            % par_file_name
            %
            if isempty(value)
                this=this.delete_par();
                return
            end
            [this.det_par_stor,this.n_detinpar_stor,this.par_file_name_stor] = check_det_par(value);
        end
        
        function fname=get.par_file_name(this)
            % get method for dependent property par_file_name
            fname = this.par_file_name_stor;
        end
        function this=set.par_file_name(this,par_f_name)
            % method checks if the ASCII file with the name par_file_name exists
            %
            % Then it sets this par file name as the source par file name and
            % clears all previous loaded par file information (if any).
            %
            
            if isempty(par_f_name)
                % disconnect detector information in memory from a par file
                this.par_file_name_stor='';
                if isempty(this.det_par)
                    this.n_detinpar_stor=[];
                end
            else
                [ok,mess,f_name] = check_file_exist(par_f_name,{'.par','.phx'});
                if ~ok
                    error('ASCIIPAR_LOADER:set_par_file_name',mess);
                end
                if ~strcmp(this.par_file_name_stor,f_name)
                    this.par_file_name_stor= f_name;
                    this.n_detinpar_stor = asciipar_loader.get_par_info(f_name);
                    this.det_par_stor=[];
                end
            end
        end
        
        function ndet = n_detectors(this)
            %method to get number of detectors
            ndet = this.n_detinpar_stor;
        end
        % ------------------------------------------------------------------
    end
    methods(Static)
        function fields = par_can_define()
            fields = {'det_par','n_detectors'};            
        end
        
        function ndet=get_par_info(par_file_name,varargin)
            % get number of detectors described in ASCII par or phx file
            
            fid=fopen(par_file_name,'rt');
            if fid==-1,
                error('ASCIIPAR_LOADER:get_par_info','Error opening file %s\n',par_file_name);
            end
            
            ndet = fscanf(fid,'%d \n',1);
            fclose(fid);
            if isempty(ndet)|| (ndet<0)|| (ndet> 4.2950e+009)
                error('ASCIIPAR_LOADER:get_par_info','Invalid par file, Error reading number of detectors from file %s\n',par_file_name);
            end
        end
    end
    
end

