classdef loader_nxspe
%  helper class to provide loading experiment data and detectors angular 
%  positions  from NeXus nxspe file, 
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision: 1 $ ($Date:  $)
%
    properties
	    % number of detectors, defined by the par data
	    n_detectors=[];
        % the variable which discribes nxspe file to load data  from
        file_name='';
        % par file name for nxspe file is the same as file_name if not
        % redefined by separate ascii par file
        par_file_name='';
        % the folder within nexus file where nxspe data are located;
        root_nexus_dir='';
        % data fields (do not have to be defined unless going to save)
        S    =[];
        ERR  =[];        
        en   =[];
        efix =[];
        psi  =[];
        det_par=[];
        %%--    the fields below are responsible for work of the class as
        %%-     part of the run_data class
        % The run_data structure fields which become defined if proper spe file is provided
        nxspe_defines={'S','ERR','en','efix','psi','det_par'};
        % current version of nxspe file
        nxspe_version='';
    end
    
    methods
    
        function this = loader_nxspe(full_nxspe_file_name)
        % the constructor for nxspe data loader
        % it verifies if the file is correct nxspe file and 
        % prepares the file for IO operations.        
        %
        %usage:
        %>>loader=loader_nxspe(full_nxspe_file_name)
        %where:
        % full_nxspe_file_name -- full file name (with path) to proper
        %                         nxspe file
        if nargin==0; return ; end;
        
         this = check_file_correct(loader_nxspe(),full_nxspe_file_name);
	
        end   
        
    end
   
    
end
