classdef rundatah < rundata
    % class responsible for transformations between single run sqw data
    % object and rundata object
    %
    properties(Dependent)
        % optional handle to function, used to transform sqw object.
        transform_sqw
    end
    properties
        % optional handle to list of q-vectors, used instead of detectors
        % positions
        qpsecs_cache = []
    end

    properties(Access=private)
        transform_sqw_f_=[];
    end

    methods(Static)
        function clear_det_cache()
            % clear cached detectors information and detectors directions
            calc_or_restore_detdcn_([]);
        end
        %
        function [runfiles_list,defined]=gen_runfiles(spe_files,varargin)
            % Returns array of rundatah objects created by the input arguments.
            %
            % Usage:
            %
            %>> [runfiles_list,file_exist] = gen_runfiles(spe_file,[par_file],arg1,arg2,...)
            %
            % See input parameters of parent rundata class static function with the same
            % name about information on input parameters
            %
            % Optional rundatah input parameters:
            %>> [runfiles_list,file_exist] = gen_runfiles(spe_file,[par_file],arg1,arg2,...
            %                                 'transform_sqw',...
            %                                 @(sqw)(transf_function))
            % where keyword transform_sqw identifies the next argument as
            % function handle to the function in the form:
            %>>sqw_transf = transf(sqw);
            % and transf is any homogeneous transformation to apply to an
            % sqw object (see symmeterize_sqw on the Horace web page for the practical
            % usage example)
            %
            % Output:
            % -------
            %   runfiles        Array of rundatah objects
            %   file_exist      boolean array  containing true for files which were found
            %                   and false for which have been not. runfiles list
            %                   would then contain members, which do not have loader
            %                   defined. Missing files are allowed only if -allow_missing
            %                   option is present as input
            %
            % Determine keyword arguments, if present
            arglist=struct('transform_sqw',[]);
            flags={};
            [args,opt,present] = parse_arguments(varargin,arglist,flags);

            [runfiles_list,defined]= rundata.gen_runfiles_of_type('rundatah',spe_files,args{:});
            % add check to verify if run_ids for all generated files are
            % unique. non-unique run_ids will be renumbered. This should
            % not normally happen, but additional check will do no harm
            runfiles_list = update_duplicated_rf_id(runfiles_list);

            if present.transform_sqw
                transf = opt.transform_sqw;
                for i=1:numel(runfiles_list)
                    if numel(transf) == 1
                        runfiles_list{i}.transform_sqw = transf;
                    else % never tried, it looks wrong
                        runfiles_list{i}.transform_sqw = transf{i};
                    end
                end
            end
        end
        %------------------------------------------------------------------
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = rundatah();
            obj = loadobj@serializable(S,obj);
        end
    end

    methods
        %
        % method to create sqw object from rundata object
        [w,grid_size,pix_range,varargout] = calc_sqw(rd,grid_size_in,pix_range_in,varargin);

        %Method calculates q-dE range, this rundata file contributes into.
        [u_to_rlu,pix_range,varargout]=calc_pix_range(obj,varargin);

        % build rundata object, which can be used for estimating sqw pix
        % ranges
        [bound_obj,obj] = build_bounding_obj(obj,varargin);

        function obj=rundatah(varargin)
            % rundatah class constructor.
            %
            % Builds rundata in a way similar to
            % herbert rundata plus additional options allowing to build it
            % from sqw
            %
            obj = obj@rundata();
            if nargin == 1 && isa(varargin{1},'sqw')
                obj = rundata_from_sqw_(varargin{1});
            else
                obj = obj.init(varargin{:});
            end
        end
        %------------------------------------------------------------------
        function tf = get.transform_sqw(obj)
            % get external transformation to apply to new sqw object
            tf = obj.transform_sqw_f_;
        end
        %
        function obj=set.transform_sqw(obj,fh)
            % define function handle to use to transform sqw
            % or clear up existing function handle
            if isempty(fh) || isa(fh,'function_handle')
                obj.transform_sqw_f_ = fh;
            else
                error('HORACE:rundatah:invalid_argument',...
                    'transform_sqw should be function handle applicable to sqw object as: w_transformed = transform_sqw(w_initial)');
            end

        end
        function proj = get_projection(obj)
            % returns instrument projection, used for conversion from
            % instrument coordinate system to Crystal Cartesian coordinate
            % system
            proj = instr_proj(obj.lattice,obj.efix,obj.emode);
            % TODO:
            % Set up symmetry transformation over pixels.
            % its good place to have it here
        end
        function [qspec,en] = calc_qspec(obj,detdcn)

            % Calculate the components of Q in reference frame fixed w.r.t. spectrometer
            %
            %   >> qspec = obj.calc_qspec(detdcn)
            %
            % Input:
            % ------
            %   detdcn  Direction of detector in spectrometer coordinates ([3 x ndet] array)
            %             [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
            %
            % Output:
            % -------
            %   qspec   Momentum in spectrometer coordinates
            %           (x-axis along ki, z-axis vertically upwards) ([3,ne*ndet] array)
            %   en      Energy transfer for all pixels ([1,ne*ndet] array)
            %
            en = obj.en;
            if size(obj.S,1)+1 == numel(en)
                en = 0.5*(en(1:end-1)+en(2:end));
            end
            [qspec,en]=calc_qspec_(detdcn,obj.efix,en,obj.emode);
        end

        function [pix_range,u_to_rlu,pix,obj] = calc_projections(obj,detdcn)
            % main function to transform rundatah information into
            % crystal Cartesian coordinate system
            %
            % Works only for crystal (powder needs to have crystal lattice
            %                         set up too)
            %
            % Usage:
            %>> [pix_range,u_to_rlu,pix,obj] = rh.calc_projections()
            %>> [pix_range,u_to_rlu,pix,obj] = rh.calc_projections(detchn)
            %
            % Inputs:
            % rh       -- fully defined (valid) rundatah object
            %
            %
            % Returns:
            % pix_range --  q-dE range of pixels in crystal Cartesian coordinate
            %             system
            % u_to_rlu -- martix to use when converting crystal Cartesian
            %             coordinate systen into rlu coordinate system
            % pix      -- PixelData object containing sqw pixel's information
            %
            %             coordinate system (see sqw pixels information on
            %             the details of the pixels format)
            % obj      -- rundatah object with all data loaded in memory
            %             and lattice units set to radian
            %
            % Substantially overlaps with calc_sqw method within all
            % performance critical aras except fully fledged sqw object is
            % not constructed

            %  Removed for the future, in anticipation of making
            %  rundata memory based only
            %             % Load data which have not been loaded in memory yet (do not
            %             % reload)
            %             obj = obj.load();
            %             % remove masked data and detectors
            %             [obj.S,obj.ERR,obj.det_par]=obj.rm_masked();

            if nargout<3
                proj_mode = 0;
            else
                proj_mode = 2;
            end
            if nargin <2
                detdcn = [];
            end
            % Calculate projections
            [u_to_rlu,pix_range,pix,obj] = obj.calc_projections_(detdcn,proj_mode);
        end
        %
        function flds = saveableFields(obj)
            flds = saveableFields@rundata(obj);
            flds = [flds,'transform_sqw'];
        end

    end

end
