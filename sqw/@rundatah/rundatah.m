classdef rundatah < rundata
    % class responsible for transformations between single run sqw data
    % object and rundata object
    %
    %
    %
    properties(Dependent)
        % optional handle to function, used to transform sqw object.
        transform_sqw
    end
    properties
        % optional handle to precaluclated detectors directions array
        detdcn_cash = []
        % optional handle to list of q-vectors, used instead of detectors
        % positions
        qpsecs_cash = []
    end
    
    properties(Access=private)
        transform_sqw_f_=[];
    end
    methods(Static)
        function clear_det_cash()
            % clear cashed detectors information and detectors directions
            calc_or_restore_detdcn_([]);
        end
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
    end
    
    methods
        %
        % method to create sqw object from rundata object
        [w,grid_size,urange,varargout] = calc_sqw(rd,grid_size_in,urange_in,varargin);
        %Method calculates q-dE range, this rundata file contributes into.
        [u_to_rlu,urange,varargout]=calc_urange(obj,varargin);
        % build rundata object, which can be used for estimating sqw ranges
        bound_obj = build_bounding_obj(obj,varargin);
        
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
                obj = obj.initialize(varargin{:});
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
                error('RUNDATAH:invalid_argument',...
                    'transform_sqw should be function handle applicable to sqw object as: w_transformed = transform_sqw(w_initial)');
            end
            
        end
        
        function [urange,u_to_rlu,pix,obj] = calc_projections(obj)
            % main function to transform rundatah information into
            % crystal cartezian coordinate system
            %
            % Works only for crystal (powder needs to have crystal lattice
            %                         set up too)
            %
            % Usage:
            %>> [urange,u_to_rlu,pix,obj] = rh.calc_projections()
            %                           where rh is fully defined rundata object
            % Returns:
            %urange --  q-dE range of pixels in crystan cartesian coordinate
            %           system
            % u_to_rlu -- martix to use when converting crystal cartezian
            %             coordinate systen into rlu coodidinate system
            % pix      -- [9 x npix] array of sqw pixel's information
            %             in crystal cartezian
            %             coordinate system (see sqw pixels information on
            %             the details of the pixels format)
            % obj      -- rundatah object with all data loaded in memory
            %             and lattice units set to radian
            %
            % Substantially overlaps with calc_sqw method within all
            % performance critical aras except fully fledged sqw object is
            % not constructed
            
            % Load data which have not been loaded in memory yet (do not
            % reload) 
            obj = obj.load();
            % remove masked data and detectors
            [obj.S,obj.ERR,obj.det_par]=obj.rm_masked();

            if nargout<3
                proj_mode = 0;
            else
                proj_mode = 2;
            end
            % Calculate projections            
            [u_to_rlu,urange,pix] = obj.calc_projections_(obj.detdcn_cash,[],proj_mode);
        end
    end
    
end

