classdef a_loader
% Base class for all data loaders used by rundata class    
%
% $Revision: 107 $ ($Date: 2011-11-24 10:51:03 +0000 (Thu, 24 Nov 2011) $)
%
    properties
        % signal
        S     = [];
        % error
        ERR   = [];
        % energy boundary
        en   = [];
	    % number of detectors, defined by the par file
	    n_detectors=[];       
        % array of detector parameters
        det_par   =[];
        % the variable which discribes spe file to load SPE data  from 
        % (S,Err, en)
        file_name='';
        % the variable which discribes par file to load ASCII PAR data  from 
        par_file_name='';
        % the data fields this loader defines 
        loader_defines={};
    end
    
    methods
        % constructor;
        function this=a_loader(varargin)
            % initiate the list of the fields this loader defines            
            if nargin>0
                this.loader_defines=varargin{:};
            else
                this.loader_defines={};
            end
        end
        
        function [det,this]=load_par(this,varargin)
        % earlier Matlab version do not support abstract methods, so this
        % is a stub for such method. 
        %
        % method loads par data into run data structure and returns it in the format,requested by user
        %
        % this function has to have its particular equivalents in 
        % all other loaders are accessed through common interface.
        %
        % usage:
        %>>det= load_par(loader,'-hor')
        %        returns detectors information loaded from correspondent data file 
        %        previously associated with load class by load constructor
        %  loader -- the class name of ASCII file loader class
        % '-hor'            -- if present request to return the data as horace structure, if not --  as 6-column array
        %
        %>>[det,loader]=load_par(loader,file_name,['-hor'])
        %               returns detectors information from the file
        %               name specified. The function alse redefines
        %               the par file name, stored in loader_ascii
        %               class
            
            error('A_LOADER:abstract_method called',' this method should be overloaded by the particular loader');            
        end
        
        function fields = defined_fields(this)
        % the method returns the cellarray of fields names, 
        % which are defined by current instance of loader 
        % class
        %usage:
        %>> fields= defined_fields(loader);
        %   loader -- the specific loader constructor or 
            if ~isempty(this.file_name)
                fields = this.loader_defines;
            else
                fields='';
            end
        end

        
        function [this,return_horace_format,new_file_name]=check_par_file(this,fext,varargin)
            
            return_horace_format = false;            
            the_file_name        = this.par_file_name;     
            new_file_name        = '';
            % verify if the parameters request other file name and horace data format;            
            if nargin>2
                [new_file_name,file_format]=parse_par_arg(the_file_name,varargin{:});
                if ~isempty(file_format)
                     return_horace_format = true;	       
                end               
                if ~strcmp(new_file_name,the_file_name)
                    this.par_file_name  = check_file_exist(new_file_name,{fext});
                end

            end
            if isempty(this.par_file_name)
                error('LOADER:load_par',' undefined input par file name');
            end
        end
    end
    
end

