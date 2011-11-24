classdef loader_ascii
% helper class to provide loading experiment data from
% ASCII spe file and  ASCII par file 
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%

    properties
        S  =[];
        ERR=[];
        en =[];
	    % number of detectors, defined by the par file
	    n_detectors=[];       
        % array of detector parameters
        det_par   =[];
        % the variable which discribes spe file to load ASCII SPE data  from
        file_name='';
        % the variable which discribes par file to load ASCII PAR data  from        
        par_file_name='';
        %%--    the fields below are responsible for work of the class as
        %%-    part of the run_data class
        % The run_data structure fields which become defined if proper spe file is provided
        spe_defines={'S','ERR','en'};
        % The run_data structure fields which become deifned if proper par
        % file is provided;
        par_defines={'det_par'};
     end
    
    methods
        function ascii_loader = loader_ascii(full_spe_file_name,par_file_name)
        % the constructor for spe data loader; called usually from run_data
        % class;
        % 
        % it verifies, if files, with names provided as input parameters exist and
        % prepares the class for future IO operations. 
        %
        % usage:
        %>> loader =loader_ascii();		
        %>> loader =loader_ascii(spe_file)		
        %>> loader =loader_ascii(spe_file,par_file)
        %		
        % where:
        %   spe_file    -- full file name (with path) for existing spe file
        %   par_file    -- full file name (with path) for existing par file
        %   
		%  If the constructor is called with a file name, the file has to exist. Check_file exist function verifies if
		% the file is present regardless of the case of file name and file extension, which forces unix file system 
		% behave like Windows file system. 
        
        
        if nargin==0; return ; end;

        if ~isa(full_spe_file_name,'char')
             error('LOAD_ASCII:wrong_argument',' first parameter has to be a file name');                
	    else
             ascii_loader.file_name =check_file_exist(full_spe_file_name,'.spe');         	 
        end
		
             
        if exist('par_file_name','var') 
            if ~isa(par_file_name,'char')
                 error('LOAD_ASCII:wrong_argument',' third parameter has to be a file name');                
		    else
            % specify par  file name for data loading;
		     ascii_loader.par_file_name = check_file_exist(par_file_name,{'.par'});			
            end
        end
        
		        
        end
        %
    end    
end

