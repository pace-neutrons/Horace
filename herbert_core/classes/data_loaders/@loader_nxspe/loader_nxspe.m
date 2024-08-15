classdef loader_nxspe < a_loader
    %  helper class to provide loading experiment data and detectors angular
    %  positions  from NeXus nxspe file,
    %
    % $Author: AB; 20/10/2011
    %
    %
    properties
        % incident energy
        efix =[];
        % rotation angle
        psi  =[];
    end
    properties(Access=private)
        % the folder within nexus file where nxspe data are located;
        root_nexus_dir_='';
        % current version of nxspe file
        nxspe_version_=[];
        % the structure, containing the folder structure of the nxspe file
        % as defined in hdf5 file
        nexus_dataset_info_ = [];
        % a structure for instrument information
        nexus_instrument_ = [];
    end
    properties(Constant,Access = private)
        % the list of field names which describe nxspe file data and loader
        % returns from file info structure (fh) used to identify loader
        % and major information about the file.
        % By chance and for simplicity, these field names correspond to
        % the name of main info fields used to set up valid data loader
        data_info_fields_ = {'n_detindata_','file_name_','en','efix','psi',...
            'nxspe_version_','root_nexus_dir_','nexus_dataset_info_'}
    end

    methods(Static)
        function fext=get_file_extension()
            % return the file extension used by this loader
            fext='.nxspe';
        end
        %
        function descr=get_file_description()
            % method returns the description of the file format loaded by this
            % loader.
            ext = loader_nxspe.get_file_extension();
            descr =sprintf('nexus spe files (MANTID): (*%s)',ext);
        end
        %
        function [ok,fh] = can_load(file_name)
            % check if the file name is nxspe file name and the file can be
            % loaded by loader_nxspe
            %
            %Usage:
            %>>[ok,fh]=loader.can_load(file_name)
            % Input:
            % file_name -- the name of the file to check
            % Output:
            %
            % ok   -- True if the file can be processed by the loader_nxspe
            % fh --  the structure, which describes nxspe file
            fh=[];
            [ok,mess,full_file_name] = check_file_exist(file_name,{'.nxspe'});
            if ~ok
                fh = mess;
                return;
            end
            if ~H5F.is_hdf5(full_file_name)
                ok = false;
                warning('LOAD_NXSPE:invalid_argument','file %s is not an hdf5 file',full_file_name);
                return;
            end
            fh =loader_nxspe.get_data_info(full_file_name);
        end
        %
        function fh =get_data_info(file_name)
            % Load header information of nxspe MANTID file
            %
            % >> fh = loader_nxspe.get_data_info(filename)
            %
            % where: 
            % fh is a structure with fields, defined by data_info_fields_
            % property and values as follows:
            %
            % ndet  -- number of detectors
            % en    -- energy bins
            % full_file_name -- the full name (with path) of the source nxpse file
            % ei             -- incident energy
            % psi            -- crystal rotation angle (should be NaN if undefined, but some versions wrongly write 0 in this case)
            % nexus_dir      -- internal nexus folder name where the data are stored
            % nxspe_ver      -- version of the nxspe data
            % nexus_datast_info -- the structure, containing all nxspe data
            %                    layout within the nexus file
            %
            if ~exist('file_name', 'var')
                error('HERBERT:loader_nxspe:invalid_argument',...
                    ' has to be called with valid file name');
            end
            [ndet,nxspe_ver,nexus_dir,nexus_datast_info] = ...
                a_detpar_loader_interface.get_nxspe_file_info(file_name);

            en = h5read(file_name,[nexus_dir,'/data/energy']);
            ei = h5read(file_name,[nexus_dir,'/NXSPE_info/fixed_energy']);
            psi = h5read(file_name,[nexus_dir,'/NXSPE_info/psi']);

            fh = cell2struct({ndet;file_name;en;ei;psi; ...
                nxspe_ver;nexus_dir;nexus_datast_info}, ...
                loader_nxspe.data_info_fields_');
        end
        %
    end
    methods
        function obj = init(obj,full_nxspe_file_name,varargin)
            % method initiates internal structure of nxspe_loader, which is responsible for
            % work with nxspe data file.
            %Usage:
            %>>loader=loader.init(full_spe_file_name,[full_par_file_name],[fh]);
            %
            %parameters:
            %full_spe_file_name -- the full name of spe data file
            %full_par_file_name -- if present -- the full name of ASCII or nxspe par file,
            %                      which overwrites detector information stored in nxspe file
            %fh                 -- if present -- the structure which describes nxspe
            %                      file and contains number of detectors
            %                      energy bins, full file name and other nxspe information for this file
            %

            obj = init@a_loader(obj,full_nxspe_file_name,varargin{:});
            if numel(varargin)>0 && istext(varargin{1})
                if isempty(varargin{1})
                    obj.par_file_name = obj.file_name;
                else
                    obj.par_file_name = varargin{1};
                end
            else
                obj.par_file_name = obj.file_name;
            end
            % Checks if file has instrument info.
            try
                obj.nexus_instrument_ = obj.read_instrument_info_();
            catch ME
                if strcmp(ME.identifier, 'HERBERT:loader_nxspe:missing_instrument_fields')
                    warning(ME.identifier,'%s', ME.message);
                end
                % Ignore all other errors; instrument info not guaranteed to
                % be in all nxspe files; its absence is not an error.
            end
        end
        %
        function obj = loader_nxspe(full_nxspe_file_name,varargin)
            % the constructor for nxspe data loader
            % it verifies if the file is correct nxspe file and
            % prepares the file for IO operations.
            %
            %usage:
            %>>loader=loader_nxspe(full_nxspe_file_name)
            %where:
            % full_nxspe_file_name -- full file name (with path) to proper
            %                         nxspe file

            obj=obj@a_loader(varargin{:});
            % The run_data structure fields which become defined if proper spe file is provided
            obj.loader_define_ ={'S','ERR','en','efix','psi','det_par','n_detectors'};

            if exist('full_nxspe_file_name', 'var')
                obj= obj.init(full_nxspe_file_name,varargin{:});
            end
        end
        %
        function fields = defined_fields(this)
            % the method returns the cellarray of fields names, which are
            % defined by nxspe file and par file if present
            %usage:
            %>> fields= defined_fields(loader);
            %
            fields = defined_fields@a_loader(this);
            % psi in nxspe file can be empty or ill defined.
            if ~isempty(this.psi) && isnan(this.psi)
                psi_loc = ismember(fields,'psi');
                fields  = fields(~psi_loc);
            end
        end
        %
        function obj = delete(obj)
            % delete all memory demanding data/fields from memory and close all
            % open files (if any)
            %
            % loader class has to be present in RHS to propagate the changes
            obj.S_ = [];
            obj.ERR_ = [];
            if ~isempty(obj.detpar_loader_)
                if isempty(obj.detpar_loader_.par_file_name)
                    obj.detpar_loader_ = [];
                else
                    obj.detpar_loader_ = obj.detpar_loader_.delete();
                end
            end
            if isempty(obj.file_name_)
                obj.en_ = [];
                obj.n_detindata_ = [];
            end
        end
        function rv = has_loaded_instrument(obj)
            rv = ~isempty(obj.nexus_instrument_);
        end
        function instrument = get_instrument(obj)
            if ~isempty(obj.nexus_instrument_)
                instrument = obj.nexus_instrument_;
            else
                instrument = obj.read_instrument_info_();
            end
        end
    end
    %
    methods(Access=protected)
        function flds = get_data_info_fields(~)
            % list of data info fields for nxspe data
            flds = loader_nxspe.data_info_fields_;
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

        function obj = find_run_id(obj)
            if obj.nxspe_version_ > 1.2
                try
                    obj.run_id_ = double(h5read(obj.file_name,[obj.root_nexus_dir_,'/instrument/run_number']));
                catch ME
                    if strcmp(ME.identifier,'MATLAB:imagesci:h5read:libraryError')
                        obj.run_id_ = NaN;
                    else
                        rethrow(ME);
                    end
                end
            else
                obj = find_run_id@a_loader(obj);
            end
        end

        function obj = set_data_file_name(obj,filename)
            % set nxspe data source accounting for the case when detector
            % parameters are also coming from the same nxspe file. Save on
            % repeated read from the file in this case
            %
            %
            if ~isempty(obj.detpar_loader_)
                if strcmp(filename,obj.par_file_name) &&...
                        ~isempty(obj.detpar_loader_.n_det_in_par)
                    if ~isa(obj.detpar_loader_,'nxspepar_loader')
                        error('HERBERT:loader_nxspe:invalid_argument',...
                            'setting non-nxspe par file %s as the source of the nxspe data',...
                            filename);
                    end
                    obj = obj.set_data_info(filename);
                else
                    obj = set_data_file_name@a_loader(obj,filename);
                end
            else
                obj = set_data_file_name@a_loader(obj,filename);
            end
        end
        function instrument = read_instrument_info_(obj)
            if ~isempty(obj.file_name)
                filename = obj.file_name;
            else
                filename = obj.par_file_name;
            end
            if ~isempty(obj.root_nexus_dir_)
                root_dir = obj.root_nexus_dir_;
            else
                root_dir = find_root_nexus_dir(filename);
            end
            h5inst = h5info(filename, [root_dir '/instrument']);
            dataset = read_nexus_groups_recursive(h5inst);
            % Instrument we support must have 'moderator' and 'source' components
            if ~any(isfield(dataset, {'moderator', 'source'}))
                error('HERBERT:loader_nxspe:invalid_instrument', ...
                    'nxspe file has instrument data incompatible with Horace');
            end
            source = IX_source(dataset.source.Name.value, '', double(dataset.source.frequency.value));
            moderator = obj.read_inst_moderator_(dataset);
            % NXSPE files *must* have a "fermi" component, so we distinguish
            % instrument types based on presence of 'shaping_chopper' and 'mono_chopper'
            % as we only have two types of instruments supported at present
            if all(isfield(dataset, {'shaping_chopper', 'mono_chopper', ...
                    'horiz_div', 'vert_div'}))
                instrument = obj.read_disk_inst_(dataset, source, moderator);
            else
                % The struct must at least have an 'aperture' field
                if ~isfield(dataset, 'aperture')
                    error('HERBERT:loader_nxspe:missing_instrument_fields', ...
                        ['nxspe file has incomplete instrument data. Please manually ' ...
                        'set instrument if you want to perform resolution convolution']);
                end
                instrument = obj.read_fermi_inst_(dataset, source, moderator);
            end
        end
        function moderator = read_inst_moderator_(obj, ds)
            % Construct an IX_moderator from a NeXus data structure
            if isfield(ds.moderator, 'pulse_shape')
                pulse_model = 'table';
                parameters = {ds.moderator.pulse_shape.Time.value ...
                    ds.moderator.pulse_shape.Intensity.value};
            elseif isfield(ds.moderator, 'empirical_pulse_shape')
                pulse_model = ds.moderator.empirical_pulse_shape.type.value;
                parameters = ds.moderator.empirical_pulse_shape.data.value;
            else
                error('HERBERT:loader_nxspe:invalid_moderator', ...
                    'moderator model in instrument info not understandable by Horace.');
            end
            moderator = IX_moderator(abs(ds.moderator.transforms.MOD_T_AXIS.value), ...
                ds.moderator.transforms.MOD_R_AXIS.value, ...
                pulse_model, parameters);
        end
        function instrument = read_fermi_inst_(obj, ds, src, mod)
            % Construct an IX_inst_DGfermi from a NeXus data structure
            aperture = IX_aperture(ds.aperture.transforms.AP_AXIS.value, ...
                ds.aperture.x_gap.value, ds.aperture.y_gap.value);
            fermi = IX_fermi_chopper(ds.fermi.type.value, abs(ds.fermi.distance.value), ...
                ds.fermi.rotation_speed.value, ds.fermi.radius.value, ...
                ds.fermi.r_slit.value, ds.fermi.slit.value);
            ei = ds.fermi.energy.value;
            name = ds.name.value;
            instrument = IX_inst_DGfermi(mod, aperture, fermi, ei, 'name', name, 'source', src);
        end
        function instrument = read_disk_inst_(obj, ds, src, mod)
            % Construct an IX_inst_DGdisk from a NeXus data structure
            ch1 = ds.shaping_chopper;
            slot_width = tand(abs(diff(ch1.slit_edges.value))) * ch1.radius.value;
            ch1 = IX_doubledisk_chopper('chopper_1', abs(ch1.transforms.CH1_T_AXIS.value), ...
                ch1.rotation_speed.value, ch1.radius.value, slot_width);
            ch5 = ds.mono_chopper;
            slot_width = tand(abs(diff(ch5.slit_edges.value))) * ch5.radius.value;
            ch5 = IX_doubledisk_chopper('chopper_5', abs(ch5.transforms.CH5_T_AXIS.value), ...
                ch5.rotation_speed.value, ch5.radius.value, slot_width);
            ang = ds.horiz_div.data.Horizontal_Divergence.value / 180 * pi;
            hdiv = IX_divergence_profile(ang, ds.horiz_div.data.Normalised_Beam_Profile.value);
            ang = ds.vert_div.data.Vertical_Divergence.value / 180 * pi;
            vdiv = IX_divergence_profile(ang, ds.vert_div.data.Normalised_Beam_Profile.value);
            instrument = IX_inst_DGdisk(mod, ch1, ch5, hdiv, vdiv, ds.fermi.energy.value, ...
                'name', ds.name.value, 'source', src);
        end
    end


end


