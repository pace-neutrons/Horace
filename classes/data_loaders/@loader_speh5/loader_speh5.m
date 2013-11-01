classdef loader_speh5 < a_loader
% helper class to provide loading experiment data from ASCII spe file, 
% ASCII par file and all necessary additional parameters
%   Detailed explanation goes here
    
    properties
        % incident energy
        efix =[];        
       % speh5 version;
        speh5_version=[];

    end
    
    methods
        function this = loader_speh5(full_speh5_file_name)
        % the constructor for spe_h5 data loader 
        % 
        % it analyzes all data fields availible  as the input arguments and
        % verifies that all necessary data are there
            speh5_defines={'S','ERR','en','efix'};                
            this=this@a_loader(speh5_defines);        
            
            if nargin==0; return ; end;

            this.file_name =  check_file_correct(full_speh5_file_name); 
            % read energy bin boundaries
            this.en  = hdf5read(this.file_name,'En_Bin_Bndrs');
    
            
  
        end      
    end
    
end
