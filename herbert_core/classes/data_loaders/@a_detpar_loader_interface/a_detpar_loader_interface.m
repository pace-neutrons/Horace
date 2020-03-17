classdef a_detpar_loader_interface
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
    %
    properties (Access=protected)
        % number of detectors, defined in the file, described by the par
        % file name
        n_detinpar_=[];
        % storage field for detector information
        det_par_=[];
        % storage field for a par file name
        par_file_name_ ='';
    end
    %----------------------------------------------------------------------
    methods(Abstract)
        % method loads par data into run data structure and returns
        % it in the format,requested by user
        [det,this]=load_par(this,varargin)
        
        % Data fields which are defined by a par file
        % ASCII Par or phx file defines det_par only (n_detectors in
        % the loader is dependent/service field) but other types of par
        % files can contain fields with additional information.
        fields = par_file_defines(this);
        
        % clear memory from loaded detectors information
        this=delete_par(this)
    end
    methods(Abstract,Access=protected)
        % get method for dependent property det_par
        det_par= get_det_par(obj);
        % get method for dependent property par_file_name
        fname = get_par_file_name(obj);
        % Method sets this par file name as the source par file name.
        obj = set_par_file_name(obj,par_f_name);
        %method to retrieve number of detectors
        ndet = get_n_det_in_par(obj);
    end
    
    %
    methods(Static,Abstract)
        % get number of detectors defined by par,phx file
        [ndet,fh]=get_par_info(par_file_name_or_handle,varargin)
        % return fields defined by appropriate detector format
        fields = par_can_define()
    end
    methods
        % -----------------------------------------------------------------
        % ---- SETTERS GETTERS FOR SPECIAL PROPERTIES     -----------------
        % -----------------------------------------------------------------
        % connected properties related to det_par location in file or in
        % memory
        function det_par=get.det_par(obj)
            % get method for dependent property det_par
            det_par= get_det_par(obj);
        end
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
        function fname=get.par_file_name(obj)
            % get method for dependent property par_file_name
            fname = get_par_file_name(obj);
        end
        %
        function obj=set.par_file_name(obj,par_f_name)
            % Method sets this par file name as the source par file name.
            %
            % Depending on the current state, it can clears all previous
            % file information from memory
            obj = set_par_file_name(obj,par_f_name);
        end
        
        function ndet = get.n_det_in_par(obj)
            % retrieve number of detectors defined by current detectors
            % info
            ndet = get_n_det_in_par(obj);
        end
        %
    end
    methods(Access=protected)
        %
        function [return_array,force_reload,getphx,lext,obj]=parse_loadpar_arguments(obj,varargin)
            % Auxiliry method processes the arguments specified with load_par methods
            %
            % usage:
            %>>this = load_par(this,'-nohor')
            %                      returns detectors information loaded from the nxspe file,
            %                      previously associated with loader_nxspe class by
            %                      loader_nxspe constructor
            %  this             -- the instance of properly initated loader class
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
            % it return it as horace structure otherwise
            
            % '-forcereload'    -- load_par command does not reload
            %                    detector information if the full file name
            %                    (with path)
            %                    stored in the horace detector structure
            %                    coinsides with par_file_name defined in
            %                    the class. Include this option if one
            %                    wants to reload this information at each
            %                    load_par.
            %
            %>>[det,this]=load_par(this,file_name,['-nohor'])
            %                     returns detectors information from the file
            %                     name specified. The function alse redefines
            %                     the file name, stored in the loader
            %
            [return_array,force_reload,getphx,lext,obj]=parse_loadpar_arguments_(obj,varargin{:});
        end
        %
        function  [det_par,n_detinpar,par_file_name] = check_det_par(obj,value)
            % method checks if value can represent par file and detectors coordinates
            % and converts this value into format, used in det_par field
            %
            [det_par,n_detinpar,par_file_name] = check_det_par_(obj,value);
        end
        %
        function fields = check_par_defined(this)
            % method checks what fields in the structure are defined from the fields
            % the par file should define.
            fields = check_par_defined_(this);
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
                obj=obj.delete_par();
                return
            end
            [obj.det_par_,obj.n_detinpar_,obj.par_file_name_] = obj.check_det_par(value);
        end
        %
        
    end
end