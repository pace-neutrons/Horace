classdef loader_speh5 < a_loader
    % helper class to provide loading experiment data from ASCII spe file,
    % ASCII par file and all necessary additional parameters
    %   Detailed explanation goes here
    %
    % $Revision$ ($Date$)
    %
    
    properties
        % incident energy
        efix =[];
    end
    properties(Access=private)
        % speh5 version;
        speh5_version=[];
    end
    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext='.spe_h5';
        end
        function descr=get_file_description()
            % method returns the description of the file format loaded by this
            % loader.
            ext = loader_speh5.get_file_extension();
            descr =sprintf('HDF5 spe files: (*%s)',ext);
        end
        
        function [ok,fh] = can_load(file_name)
            % check if the file name is spe file name and the file can be
            % loaded by loader_ascii
            %
            %Usage:
            %>>[ok,fh]=loader.is_loader_correct(file_name)
            % Input:
            % file_name -- the name of the file to check
            % Output:
            %
            % ok   -- True if the file can be processed by the loader_ascii
            % fh --  the structure, which describes spe file
            fh=[];
            [ok,mess,full_file_name] = check_file_exist(file_name,{'.spe_h5'});
            if ~ok
                return;
            end
            if ~H5F.is_hdf5(full_file_name)
                ok = false;
                warning('LOAD_SPEH5:can_load','file %s is not an hdf5 file',full_file_name);
                return;
            end
            [ndet,en,full_file_name,ei,spe_h5ver]=loader_speh5.get_data_info(file_name);
            fh = struct('n_detectors',ndet,'en',en,'file_name',full_file_name,'ei',ei,'speh5_version',spe_h5ver);
        end
        
        function [ndet,en,full_file_name,ei,spe_h5Ver]=get_data_info(file_name)
            % Load general information from spe file written into hdf5
            % format by Libisis
            %
            % >> [ndet,en,full_file_name,ei,spe_h5Ver] = loader_speh5.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % en    -- energy bins
            %
            %
            %second form requests file to be already defined in loader
            %first form just reads file info from given spe file name.
            if ~exist('file_name','var')
                error('LOAD_SPEH5:get_data_info',' has to be called with valid file name');
            end
            
            if ischar(file_name)
                [ok,mess,full_file_name] = check_file_exist(file_name,{'.spe_h5'});
                if ~ok
                    error('LOAD_SPEH5:get_data_info',mess);
                end
            else
                error('LOAD_SPEH5:get_data_info',' has to be called with valid file name');
            end
            
            data_info=find_dataset_info(full_file_name,'','S(Phi,w)');
            if isempty(full_file_name)
                error('LOADER_SPEH5:get_data_info',[' can not identify the data structure location'...
                    ' the file %s is not proper spe_h5 file'],full_file_name);
            end
            ndet =  data_info.Dims(2);
            en   =  hdf5read(full_file_name,'En_Bin_Bndrs');
            spe_h5Ver = hdf5read(full_file_name,'spe_hdf_version');
            if spe_h5Ver >= 2
                ei   =  hdf5read(full_file_name,'Ei');
            else
                ei  = NaN;
            end
        end
    end
    
    
    methods
        function this = init(this,speh5_file_name,par_file_name,fh)
            % method initate internal structure of loader_speh5, which is responsible for
            % work with spe data file written into hdf5 format.
            %Usage:
            %>>loader=loader.init(full_spe_file_name,[full_par_file_name],[fh]);
            %
            %parameters:
            %full_spe_file_name -- the full name of spe data file
            %full_par_file_name -- if present -- the full name of par file
            %fh                 -- if present -- the structure which describes ascii spe
            %                      file and contains number of detectors
            %                      energy bins and other spe_h5 information
            this.loader_defines ={'S','ERR','en','n_detectors'};
            if ~exist('speh5_file_name','var')
                return
            end
            
            
            if exist('par_file_name','var')
                if isstruct(par_file_name) && ~exist('fh','var')
                    fh = par_file_name; % second parameters defines spe_h5 file structure
                else
                    this.par_file_name = par_file_name;
                end
            end
            
            if exist('fh','var')
                this.n_detindata_ = fh.n_detectors;
                this.en_          = fh.en;
                this.efix             = fh.ei;
                this.speh5_version    = fh.speh5_version;
                this.data_file_name_ = fh.file_name;
            else
                this.file_name =speh5_file_name;
            end
            
        end
        
        function this = loader_speh5(full_speh5_file_name,varargin)
            % the constructor for spe_h5 data loader
            %
            % it analyzes all data fields availible  as the input arguments and
            % verifies that all necessary data are there
            
            this=this@a_loader(varargin{:});
            if exist('full_speh5_file_name','var')
                this = this.init(full_speh5_file_name);
            else
                this = this.init();
            end
            
        end
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names, which are
            % defined by hdf5 spe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = defined_fields@a_loader(this);
            if ~isempty(this.speh5_version) && this.speh5_version >=2
                fields = [fields,'efix'];
            end
        end
        function this = set_data_info(this,full_speh5_file_name)
            % obtain data file information and store it into the class
            [this.n_detindata_,this.en_,this.data_file_name_, ...
                this.efix,this.speh5_version]=loader_speh5.get_data_info(full_speh5_file_name);
        end
        
        
    end
    
end
