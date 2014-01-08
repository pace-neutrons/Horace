classdef a_loader
    % Base class for all data loaders used by the rundata class
    %
    %Has two purposes:
    %1) Defines the interface for all common methods, used by loaders
    %
    %2) Defines methods used to load detector parameters from ASCI par or phx file
    %   when the main data file does not contain detector information or
    %   detector parameters have to be redefined form ASCII data file.
    %
    % A new particular loader should define all abstract methods defined by this
    % loader and register new loader with the loaders_factory class.
    %
    % If the main data file contains detector information, new loader should also
    % overload methods responsible for loading detector's information to work
    % both with ASCII par files and the detector information containing in
    % the main data file (if the later intended to be used)
    %
    % $Revision$ ($Date$)
    %
    % the properties common for all data loaders.
    properties
        % public get, protected set
        % signal
        S     = [];
        % error
        ERR   = [];
        % energy boundaries
        en   = [];
        % the variable which describes the file from which main part or
        % all data should be loaded
        file_name='';
        % the data fields which are defined in the main data file
        loader_defines={};
    end
    properties(Dependent)
        % array of detector parameters
        det_par   =[];
        % the variable which describes the name of ASCII par file which, if present
        % contain detector information overwriting existing or providing
        % missing information about the detectors angular positions
        par_file_name='';
        % number of detectors, defined in the file, described by the par
        % file name
        n_detectors=[];
        
    end
    properties (Access=private)
        % helper properties used in set/get number of detectors
        internal_call=false;
        n_det_in_par_stor=[];
        n_det_in_data_stor=[];
        det_par_stor=[];
        par_file_name_stor ='';
    end
    %
    methods(Abstract, Static)
        [ok,fh] = can_load(file_name);
        % method checks if the file_name can be processed by this file loader
        %
        %>>[is,fh]=loader.can_load(file_name)
        % Input:
        % file_name -- the name of the file to check
        % Output:
        %
        % is -- True if the file can be processed by the loader
        % fh -- (optional) the information which accelerates work with file
        %        recognized as suitable for a loader e.g. open file handle
        %        for an ASCII file to load. This information is used by
        %        loader's init function.
        [ndet,en,varargout]=get_data_info(file_name);
        % get information about spe-part of data defined in the data file
        % namely number of detectors and the energy bins
        %
        descr=get_file_description();
        % get the description of the file format, (e.g. used in GUI)
        %
        fext=get_file_extension();
        % returns the file extension used by this loader
    end
    
    methods(Abstract)
        [varargout]=load_data(this,varargin);
        % Get number of detectors and energy boundaries defined in the
        % data file or/and par file if such file is defined and
        % check the correspondence between spe and par part of the file
        % if detector information is defined separately from the main data.
        % e.g. ASCII spe file
        %
        % loader class has to be present in RHS if the data fields obtained
        % from the file need to be stored in the class and reused later
        %
        %
        %
        
        this=init(this,data_file_name,varargin);
        % the method initializes which performs main part of the constructor.
        % Invoked separately it initializes a loader, defined by empty
        % construtcor.
        %
        % Common constructor of specific loader the_loader should have a form similar to
        % the following:
        %
        % funciton this = the_loader(data_file,par_file,varargin)
        %   this =the_loader@a_loader(par_file);
        %   this=this.init(data_file,varargin);
        % end
        %function this=delete(this) -- made non-abstract generic
    end
    
    methods
        % constructor;
        function this=a_loader(varargin)
            % initiate the list of the fields this loader defines
            %>>Accepts:
            %   default empty constructor:
            %>>this=a_loader();
            %   constructor, which specifies par file name:
            %>>this=a_loader(par_file_name);
            %   copy constructor:
            %>>this=a_loader(other_loader);
            %
            if nargin>0
                if isstring(varargin{1})
                    this.par_file_name = varargin{1};
                elseif isa(varargin{1},'a_loader')
                    this=varargin{1};
                else
                    error('A_LOADER:invalid_argument','a_loader constructor argument can be only par file name or other loader')
                end
            else
            end
        end
        function this=set.file_name(this,new_name)
            % method checks if a file with the name file_name exists
            %
            % Then it sets this file name as the source par file name and
            % clears all previously loaded run information information (if any) occupying substantial memory.
            
            if isempty(new_name)
                this.file_name = '';
                this=this.delete();
                this.en = [];
                return
            else
                [ok,mess,f_name] = check_file_exist(new_name,this.get_file_extension());
                if ~ok
                    error('A_LOADER:set_file_name',mess);
                end
            end
            if ~strcmp(this.file_name,f_name)
                this.file_name = f_name;
                this= this.delete();
                this.en = [];
            else
                return
            end
            
        end
        function [ok,mess,ndet,en]=is_loader_valid(this)
            % method checks if a loader is fully defined and valid
            %Usage:
            %[ok,message,ndet,en]=loader.is_loader_valid();
            %
            %ok =  -1 if loader is undefined,
            %         0 if it is incosistant (e.g size(S) ~= size(ERR)) or size(en,1)
            %         ~=size(S,2) etc...
            %
            % if ok =1, ndet  and en should be defined. This method can not
            % be defined for a_loader, as uses abstract class methods,
            % defined in particular loaders
            [ok,mess,ndet,en] = is_loader_valid_internal(this);
        end
        function [det,this]=load_par(this,varargin)
            % method loads par data into run data structure and returns it in the format,requested by user
            %
            % this function has to have its eqivalents in all other loader classes
            % as all loaders are accessed through common interface.
            %
            % usage:
            %>>[det,this]= load_par(this,'-hor')
            %                      returns detectors information loaded from the nxspe file,
            %                      previously associated with loader_nxspe class by
            %                      loader_nxspe constructor
            %  this             -- the instance of properly initated loader class
            % '-hor'            -- if present request to return the data as horace structure,
            %
            %                      if not --  as (6,ndet) array with fields:
            %
            %     1st column    sample-detector distance
            %     2nd  "        scattering angle (deg)
            %     3rd  "        azimuthal angle (deg)
            %                   (west bank = 0 deg, north bank = -90 deg etc.)
            %                   (Note the reversed sign convention cf .phx files)
            %     4th  "        width (m)
            %     5th  "        height (m)
            %     6th  "        detector ID
            %
            %>>[det,this]=load_par(thisP{,file_name,['-hor'])
            %                     returns detectors information from the file
            %                     name specified. The function alse redefines
            %                     the nxspe file name, stored in loader_nxspe
            %                     class, if loader_nxpse was the variable of
            %                     loader_nxspe class
            %
            [return_horace_format,file_changed,new_file_name,lext]=parse_par_file_arg(this,{'.par','.phx'},varargin{:});
            
            if file_changed
                this.par_file_name = new_file_name;
            end
            if isempty(this.par_file_name)
                error('A_LOADER:load_par','Attempting to load detector parameters but the parameters file is not defined')
            end
            
            
            if file_changed || isempty(this.det_par)
                if nargout>1
                    [det,this] = load_phx_or_par_private(this,return_horace_format,lext);
                else
                    det = load_phx_or_par_private(this,return_horace_format,lext);
                end
            else
                det = this.det_par;
            end
        end
        function [ndet,en,this]=get_run_info(this)
            % Get number of detectors and energy boundaries defined by the class
            % the spe file and in connected to it ascii par or phx file
            %
            % >> [ndet,en] = get_par_info(loader_ascii)
            
            %  loader_ascii    -- is the instance of loader_ascii file.
            %  ndet            -- number of detectors defined in par file
            %  en              -- energy boundaries, defined in spe file;
            %
            %
            
            [ok,mess,ndet,en] = is_loader_valid(this);
            if ok<1
                error('A_LOADER:get_run_info',mess);
            end
            
            if isempty(this.en)
                this.en = en;
            end
            if isempty(this.n_detectors)
                this.n_detectors = ndet;
            end
        end
        %                       
        function this=delete_par(this)
            % clear memory from loaded detectors information
            this.det_par=[];
        end
        function this=delete(this)
            % delete all memory demanding data/fields from memory and close all
            % open files (if any)
            %
            % loader class has to be present in RHS to propagate the changes
            % Deleter is generic untill loaders fields are generic. Any specific
            % deleter should be overloaded
            %
            %
            this.S = [];
            this.ERR = [];
            this=this.delete_par();
        end
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names,
            % which are defined by current instance of loader class
            %
            % e.g. loader_ascii defines {'S','ERR','en','n_detectrs} if par file is not defined and
            % {'S','ERR','en','det_par'} if it is defined and loader_nxspe defines
            % {'S','ERR','en','det_par','efix','psi'}(if psi is set up)
            %usage:
            %>> fields= defined_fields(loader);
            %   loader -- the specific loader constructor
            %
            
            % the method returns the cellarray of fields names, which are
            % defined by ascii spe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = check_defined_fields(this);
        end        
        function fields = par_file_defines(this)
            % Data fields which are defined by a par file
            % ASCII Par or phx file defines det_par only (all other fields in
            % the loader are dependent/service fields) but other future par
            % files can contain fields with additional information.
            % For such loader this method should be overloaded
            
            %usage:
            %>> fields= par_file_defines(loader);
            %   loader -- the specific loader constructor
            %
            fields = check_par_defines(this);
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
            % If the par_file_name is empty this operation also sets
            % par_file_name to 'memory.par'. If not, the par_file_name reamains
            % unchanged
            %
            %
            if isempty(value)
                this.det_par_stor = [];
                if isempty(this.par_file_name)
                    this.n_det_in_par_stor = [];
                end
                return
            end
            %[this.det_par,this.n_detectors] = check_det_par(value);
            [this.det_par_stor,this.n_det_in_par_stor] = check_det_par(value);
            if ~this.internal_call
                this.par_file_name_stor='';
            end
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
                this.par_file_name_stor='';
                if isempty(this.det_par)
                    this.n_det_in_par_stor=[];
                end
            else
                [ok,mess,f_name] = check_file_exist(par_f_name,{'.par','.phx'});
                if ~ok
                    error('A_LOADER:set_par_file_name',mess);
                end
                if ~strcmp(this.par_file_name,f_name)
                    %this.par_file_name = f_name;
                    %this.n_detectors = a_loader.get_par_info(f_name);
                    this.par_file_name_stor= f_name;
                    this.n_det_in_par_stor = a_loader.get_par_info(f_name);
                else
                    return;
                end
            end
            this.det_par_stor=[];
        end
        function ndet = get.n_detectors(this)
            %method to get number of detectors
            ndet = this.n_det_in_par_stor;
            if isempty(ndet)
                ndet = this.n_det_in_data_stor;
            end
        end
        function this = set.n_detectors(this,val)
            %method to set number of detectors
            this.n_det_in_data_stor = val;
            
        end
        function isit = check_ndet_consistent(this)
            % method checks if the detector information specified for data
            % file and for detector file are consistent
            %Returns
            % -1 if data or detectors are not yet defined
            % 0  if they are not consitent
            % 1  if they are consistent and equal to each other.
            if isempty(this.n_det_in_data_stor) || isempty(this.n_det_in_par_stor)
                isit = -1;
            else
                if this.n_det_in_data_stor == this.n_det_in_par_stor
                    isit = 1;
                else
                    isit = 0;
                end
            end
        end
        % ------------------------------------------------------------------
    end
    methods(Static)
        function ndet=get_par_info(par_file_name,varargin)
            % get number of detectors described in ASCII par or phx file
            
            fid=fopen(par_file_name,'rt');
            if fid==-1,
                error('A_LOADER:io_error','Error opening file %s\n',par_file_name);
            end
            
            ndet = fscanf(fid,'%d \n',1);
            fclose(fid);
            if isempty(ndet)|| (ndet<0)|| (ndet> 4.2950e+009)
                error('A_LOADER:invalid_par_file','Error reading number of detectors from file %s; wrong file format?\n',par_file_name);
            end
        end
    end
    
end

