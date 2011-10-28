classdef loader_speh5
% helper class to provide loading experiment data from ASCII spe file, 
% ASCII par file and all necessary additional parameters
%   Detailed explanation goes here
    
    properties
        % input energy (efix);
        efix  = [];
        % signal
        S     = [];
        % error
        ERR   = [];
        % energy boundary
        en   = []
        % number of detectors, which describe the run
        n_detectors=[];
        %
        % the variable which discribes spe_h5 file to load SPE_h5 data  from
        file_name='';
        % the name of the file to get data from; it is undefined by loader
        % speh5 but can be defined by other loader or function
        par_file_name='';
        % speh5 version;
        speh5_version=[];
    end
    
    methods
        function this = loader_speh5(full_speh5_file_name)
        % the constructor for spe_h5 data loader 
        % 
        % it analyzes all data fields availible  as the input arguments and
        % verifies that all necessary data are there
            if nargin==0; return ; end;

            this.file_name =  check_file_correct(full_speh5_file_name); 
            % read energy bin boundaries
            this.en  = hdf5read(this.file_name,'En_Bin_Bndrs');
    
            
  
        end      
    end
    
end
