classdef loader_ascii < a_loader
    % helper class to provide loading experiment data from
    % ASCII spe file and  ASCII par file
    %
    % $Author: Alex Buts; 20/10/2011
    %
    % $Revision$ ($Date$)
    %
    
    properties
        %%--    the fields below are responsible for work of the class as
        %%-    part of the run_data class
    end
    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext={'.spe'};
        end
        function descr=get_file_description()
        % method returns the description of the file format loaded by this
        % loader.
            ext = loader_ascii.get_file_extension();
            descr =sprintf('ASCII spe files: (*.%s)',ext{1});
            
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
            [ok,mess,full_file_name] = check_file_exist(file_name,{'.spe'});
            if ~ok
                return;
            end
            if H5F.is_hdf5(full_file_name)>0
                ok = false;
                warning('LOADER_ASCII:is_loader_correct','file %s with extension .spe is hdf5 file',full_file_name);
                return;
            end
            [ndet,en,full_file_name]=loader_ascii.get_data_info(file_name);
             fh = struct('n_detectors',ndet,'en',en,'file_name',full_file_name);           
        end
        
        function [ndet,en,full_file_name]=get_data_info(file_name)
            % Load header information of VMS format ASCII .spe file
            %
            % >> [ndet,en,full_file_name] = loader_ascii.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % en    -- energy bins
            % full_file_name -- 
            %
            %second form requests file to be already defined in loader
            %first form just reads file info from given spe file name.
            %
            if ~exist('file_name','var')
                error('LOAD_ASCII:get_data_info',' has to be called with valid file name');
            end
            
            if isstring(file_name)              
                [ok,mess,full_file_name] = check_file_exist(file_name,{'.spe'});
                if ~ok
                    error('LOAD_ASCII:get_data_info',mess);
                end
            else
                error('LOAD_ASCII:get_data_info',' has to be called with valid file name');                
            end
            %                
            % get info about ascii spe file;
            [ne,ndet,en]= get_spe_matlab(full_file_name,'-info_only');
            if numel(en) ~= ne+1
                error('LOADER_ASCII:get_data_info',' ill formatted ascii spe file %s',file_name);
            end
        end
    end
    
    methods
        function ascii_loader = init(ascii_loader,full_spe_file_name,full_par_file_name,fh)
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

            ascii_loader.loader_defines ={'S','ERR','en','n_detectors'};
            if ~exist('full_spe_file_name','var')
                return
            end

            % set up file name checking that the file in fact exist and
            % correct
            ascii_loader.file_name =full_spe_file_name; 

            
            if exist('full_par_file_name','var')      
                if isstruct(full_par_file_name) && ~exist('fh','var')
                    fh = full_par_file_name; % second parameters defines spe file structure
                else
                    ascii_loader.par_file_name = full_par_file_name;
                end
            end
            if exist('fh','var')
                if isempty(ascii_loader.n_detectors)
                    ascii_loader.n_detectors= fh.n_detectors;
                end
                ascii_loader.en          = fh.en;
            else
               [n_det,ascii_loader.en]=ascii_loader.get_data_info(full_spe_file_name);
               if isempty(ascii_loader.n_detectors)
                   ascii_loader.n_detectors = n_det;
               end
               
            end

        end
        function ascii_loader = loader_ascii(full_spe_file_name,varargin)
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
            % The run_data structure fields which become defined if proper spe file is provided
                       
            ascii_loader=ascii_loader@a_loader(varargin{:});
            if exist('full_spe_file_name','var')
                ascii_loader = ascii_loader.init(full_spe_file_name);
            else
                ascii_loader = ascii_loader.init();
            end
            
        end
            
     end
end

