classdef loader_ascii < a_loader
    % helper class to provide loading experiment data from
    % ASCII spe file and  ASCII par file
    %
    properties(Constant)
        % when read ASCII data, keep the specified number of digits after
        % decimal point to obtain consistent results on different operating
        % systems
        ASCII_DATA_ACCURACY = 4;
    end
    properties(Constant,Access = private)
        % the list of field names which describe nxspe file data and loader
        % returns from file info structure (fh) used to identify loader
        % and major information about the file.
        % By chance and for simplicity, these field names correspond to
        % the name of main info fields used to set up valid data loader
        data_info_fields_ = {'n_detindata_','file_name_','en'};
    end



    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext='.spe';
        end
        %
        function descr=get_file_description()
            % method returns the description of the file format loaded by this
            % loader.
            ext = loader_ascii.get_file_extension();
            descr =sprintf('ASCII spe files: (*%s)',ext);

        end
        %
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
                fh=mess;
                return;
            end
            if H5F.is_hdf5(full_file_name)>0
                ok = false;
                warning('LOADER_ASCII:is_loader_correct','file %s with extension .spe is hdf5 file',full_file_name);
                return;
            end
            fh=loader_ascii.get_data_info(file_name);
        end
        %
        function fh = get_data_info(file_name)
            % Load header information of VMS format ASCII .spe file
            %
            % >> [ndet,en,full_file_name] = loader_ascii.get_data_info(filename)
            %
            % where:
            % ndet  -- number of detectors
            % full_file_name -- the full (with the path) file name with the spe information. On unix machines this
            %                   name can be also modified to have the extension case correspondent to the existing spe file
            %                   (e.g .spe if lower case extension spe file exist or SPE if upper case extension file exist)
            % en    -- energy bins
            %
            %
            if ~exist('file_name', 'var')
                error('HERBERT:loader_ascii:invalid_argument',...
                    ' has to be called with valid file name');
            end

            if ischar(file_name)
                [ok,mess,full_file_name] = check_file_exist(file_name,{'.spe'});
                if ~ok
                    error('HERBERT:loader_ascii:invalid_argument',...
                        mess);
                end
            else
                error('HERBERT:loader_ascii:invalid_argument',...
                    ' has to be called with valid file name');
            end
            %
            % get info about ascii spe file;
            [ne,ndet,en]= get_spe_(full_file_name,'-info_only');
            if numel(en) ~= ne+1
                error('HERBERT:loader_ascii:invalid_argument',...
                    ' Ill formatted ascii spe file %s',file_name);
            end
            fh = cell2struct({ndet;full_file_name;en},loader_ascii.data_info_fields_');
        end
    end


    methods
        function obj = loader_ascii(full_spe_file_name,varargin)
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

            obj=obj@a_loader(varargin{:});
            obj.loader_define_ ={'S','ERR','en','n_detectors'};
            if exist('full_spe_file_name', 'var')
                obj = obj.init(full_spe_file_name);
            else
                obj = obj.init();
            end

        end
        %
    end


    methods(Access=protected)
        function flds = get_data_info_fields(~)
            % list of data info fields for ascii data
            flds = loader_ascii.data_info_fields_;
        end
        function obj = set_info_fields(obj,fh,field_names)
            % generic method, used to set fields which define loader
            % for every appropriate. Have to be overloaded to have access
            % to private fields
            nf = numel(field_names);
            for i=1:nf
                obj.(field_names{i}) = fh.(field_names{i});
            end
        end
    end
end


