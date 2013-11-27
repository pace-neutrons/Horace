classdef loader_nxspe < a_loader
%  helper class to provide loading experiment data and detectors angular 
%  positions  from NeXus nxspe file, 
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%
    properties
	    % the folder within nexus file where nxspe data are located;
        root_nexus_dir='';
        % incident energy
        efix =[];
        % rotation angle
        psi  =[];
        %%--    the fields below are responsible for work of the class as
        %%-     part of the run_data class
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
        % The run_data structure fields which become defined if proper spe file is provided
        
        nxspe_defines={'S','ERR','en','efix','psi','det_par'};       
        this=this@a_loader(nxspe_defines);

        if nargin==0; return ; end;
        
         this = check_file_correct(loader_nxspe(),full_nxspe_file_name);
	
        end   
        
    end
   
    
end
