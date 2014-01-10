classdef loader_nxspe < a_loader
    %  helper class to provide loading experiment data and detectors angular
    %  positions  from NeXus nxspe file,
    %
    % $Author: Alex Buts; 20/10/2011
    %
    % $Revision$ ($Date$)
    %
    properties
        % incident energy
        efix =[];
        % rotation angle
        psi  =[];
    end
    properties(Access=private)
        % the folder within nexus file where nxspe data are located;
        root_nexus_dir='';
        % current version of nxspe file
        nxspe_version='';
    end
    
    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext={'.nxspe'};
        end
        function descr=get_file_description()
            % method returns the description of the file format loaded by this
            % loader.
            ext = loader_nxspe.get_file_extension();
            descr =sprintf('nexus spe files (MANTID): (*%s)',ext{1});
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
            [ok,~,full_file_name] = check_file_exist(file_name,{'.nxspe'});
            if ~ok
                return;
            end
            if ~H5F.is_hdf5(full_file_name)
                ok = false;
                warning('LOAD_NXSPE:can_load','file %s is not an hdf5 file',full_file_name);
                return;
            end
            [ndet,en,full_file_name,ei,psil,nexus_dir,nxspe_ver]=loader_nxspe.get_data_info(file_name);
            fh = struct('n_detindata_stor',ndet,'en',en,'data_file_name_stor',full_file_name,...
                'efix',ei,'psi',psil,'root_nexus_dir',...
                nexus_dir,'nxspe_version',nxspe_ver);
        end
        function [ndet,en,full_file_name,ei,psi,nexus_dir,nxspe_ver]=get_data_info(file_name)
            % Load header information of nxspe MANTID file
            %
            % >> [ndet,en,full_file_name,ei,psi,nexus_ver,nexus_dir] = loader_nxspe.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % en    -- energy bins
            % full_file_name -- the full name (with path) of the nxpse file
            % ei    -- incident energy
            % psi   -- crystal rotation angle (should be NaN if undefined, but some )
            % nexus_dir -- internal nexus folder name where the data can be
            %              located
            % nxspe_ver -- version of the nxspe data
            %
            %second form requests file to be already defined in loader
            %first form just reads file info from given spe file name.
            %
            if ~exist('file_name','var')
                error('LOAD_NXSPE:get_data_info',' has to be called with valid file name');
            end
            [ndet,en,full_file_name,nexus_dir,ei,psi,nxspe_ver]= check_file_correct_get_info(file_name);
        end
        
        
    end
    methods
        function this = init(this,full_nxspe_file_name,full_par_file_name,fh)
            % method initate internal structure of ascii_loader, which is responsible for
            % work with spe data file.
            %Usage:
            %>>loader=loader.init(full_spe_file_name,[full_par_file_name],[fh]);
            %
            %parameters:
            %full_spe_file_name -- the full name of spe data file
            %full_par_file_name -- if present -- the full name of par file
            %fh                 -- if present -- the structure which describes ascii spe
            %                      file and contains number of detectors
            %                      energy bins and full file name for this file
            %
            this.loader_defines ={'S','ERR','en','efix','psi','det_par','n_detectors'};
            if ~exist('full_nxspe_file_name','var')
                return
            end
            
            if exist('full_par_file_name','var')
                if isstruct(full_par_file_name) && ~exist('fh','var')
                    fh = full_par_file_name; % second parameters defines nxspe file structure
                else
                    this.par_file_name = full_par_file_name;
                end
            end
            if exist('fh','var')
                defined_fields = fields(fh);
                for i=1:numel(defined_fields)
                    this.(defined_fields{i}) = fh.(defined_fields{i});
                end
            else
                % set up file name checking that the file in fact exists and
                % correct
                this.file_name =full_nxspe_file_name;
                
            end
            
        end
        
        function this = loader_nxspe(full_nxspe_file_name,varargin)
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
            
            this=this@a_loader(varargin{:});
            if exist('full_nxspe_file_name','var')
                this= this.init(full_nxspe_file_name);
            else
                this = this.init();
            end
        end
        
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names, which are
            % defined by nxspe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = defined_fields@a_loader(this);
            if ~isempty(this.psi) && isnan(this.psi)
                psi_loc = ismember(fields,'psi');
                fields  = fields(~psi_loc);
            end
        end
        function this = set_data_info(this,nxspe_file_name)
            % obtain data file information and set it into class
            [this.n_detindata_stor,this.en_stor,this.data_file_name_stor,...
                this.efix,this.psi,...
                this.root_nexus_dir,this.nxspe_version]=...                
                loader_nxspe.get_data_info(nxspe_file_name);
        end
    end
    methods(Static)
        function ndet=get_par_info(par_file_name,file_name)
            % get number of detectors described in ASCII par or phx file
            if ~isempty(par_file_name)
                ndet = a_loader.get_par_info(par_file_name);
            else
                ndet =  loader_nxspe.get_data_info(file_name);
            end
        end
    end
    
end

