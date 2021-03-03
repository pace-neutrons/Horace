classdef (InferiorClasses = {?d0d, ?d1d, ?d2d, ?d3d, ?d4d}) sqw < SQWDnDBase
    %SQW Create an sqw object
    %
    % Syntax:
    %   >> w = sqw ()               % Create a default, zero-dimensional SQW object
    %   >> w = sqw (struct)         % Create from a structure with valid fields (internal use)
    %   >> w = sqw (filename)       % Create an sqw object from a file
    %   >> w = sqw (sqw_object)     % Create a new SQW object from a existing one

    properties
        main_header
        header
        detpar
        % CMDEV: data now a dependent property, below
    end
    
    properties(Dependent)
        data;
    end

    methods (Access = private)
    end
    
    methods
        [nd, sz] = dimensions(w);
        wout = sigvar(w);
        w = sigvar_set(win, sigvar_obj);
        [s,var,mask_null] = sigvar_get (win);
        sz = sigvar_size(w);
        [sel,ok,mess] = mask_points (win, varargin);
        varargout = multifit (varargin);
        varargout = multifit_sqw (varargin);
        varargout = multifit_sqw_sqw (varargin);
        varargout = tobyfit (varargin);
        [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
                                                          sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, indx);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
                                                           sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx);
        [ok,mess,varargout] = parse_pixel_indicies (win,indx,iw);
        wout=combine_sqw(w1,w2);
        save (w, varargin);
        wout=rebin_sqw(win,varargin);
        wout=symmetrise_sqw(win,v1,v2,v3);
        [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin);
        wtot=combine_cuts(w);
        wout=recompute_bin_data_tester(sqw_obj);
        wout = func_eval (win, func_handle, pars, varargin);
        wout = dnd (win);
        [header_ave, ebins_all_same]=header_average(header);

		%{
        %[deps,eps_lo,eps_hi,ne]=energy_transfer_info(header);
        [figureHandle, axesHandle, plotHandle] = plot(w,varargin);
        wout = IX_dataset_1d (w);
        wout = IX_dataset_2d (w);
        wout = IX_dataset_3d (w);
		%}
        status = adjust_aspect(w);
        varargout = resolution_plot (w, varargin);
        wout = noisify(w,varargin);
        
        function obj = sqw(varargin)
            obj = obj@SQWDnDBase();

            [args] = obj.parse_args(varargin{:});

            % i) copy
            if ~isempty(args.sqw_obj)
                obj = copy(args.sqw_obj);

            % ii) filename
            elseif ~isempty(args.filename)
                obj = obj.init_from_file(args.filename, args.pixel_page_size);

            % iii) struct
            elseif ~isempty(args.data_struct)
                obj = obj.init_from_loader_struct(args.data_struct);
            end
        end
        
        %% Public getters/setters expose all wrapped data attributes
        function val = get.data(obj)
            val = '';
            if ~isempty(obj.data_)
                val = obj.data_;
            end
        end
        function obj = set.data(obj, d)
            obj.data_ = d;
        end


    end

    methods(Static)
        %TODO: disabled until full functionality is implemeneted in new class;
        % The addition of this method causes sqw_old tests to incorrectly load data from .mat files
        % as new-SQW class objects
        
        function obj = loadobj(S)
            % Load a sqw object from a .mat file
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            %
            % -------
            % Output:
            %   obj     An instance of this object
            obj = sqw(S);
            if isa(S,'sqw')
               obj = S;
               return
            end
            if numel(S)>1
               tmp = sqw();
               obj = repmat(tmp, size(S));
               for i = 1:numel(S)
                   obj(i) = sqw(S(i));
               end
            else
               obj = sqw(S);
            end
        end
    end

    methods(Access = protected)
        wout = unary_op_manager(obj, operation_handle);
        wout = binary_op_manager_single(w1, w2, binary_op);
        [ok, mess] = equal_to_tol_internal(w1, w2, name_a, name_b, varargin);
    end

    methods(Static, Access = private)
        % Signatures of private functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();
        main_header = make_sqw_main_header();
        wout = recompute_bin_data(w);

        function args = parse_args(varargin)
            % Parse a single argument passed to the SQW constructor
            %
            % Return struct with the data set to the appropriate element:
            % args.filename  % string, presumed to be filename
            % args.sqw_obj   % SQW class instance
            % args.data_struct % generic struct, presumed to represent SQW
            % args.pixel_page_size % size of PixelData page in bytes
            parser = inputParser();
            parser.KeepUnmatched = true;  % ignore unmatched parameters
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || is_string(x) || isstruct(x)));
            parser.addParameter('pixel_page_size', PixelData.DEFAULT_PAGE_SIZE, ...
                            @PixelData.validate_mem_alloc);
            parser.parse(varargin{:});

            input = parser.Results.input;
            args = struct('sqw_obj', [], 'filename', [], 'data_struct', [], 'pixel_page_size', []);

            args.pixel_page_size = parser.Results.pixel_page_size;

            if isa(input, 'SQWDnDBase')
                if isa(input, 'DnDBase')
                    error('SQW:sqw', 'SQW cannot be constructed from a DnD object');
                end
                args.sqw_obj = input;
            elseif is_string(parser.Results.input)
                args.filename = input;
            elseif isstruct(input) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = make_sqw(0);
            end
        end
    end

    methods(Access = 'private')
        function obj = init_from_file(obj, in_filename, pixel_page_size)
            % Parse SQW from file
            %
            % An error is raised if the data file is identified not a SQW object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type, 'a') % not a valid sqw-type structure
                error('SQW:sqw', 'Data file does not contain valid sqw-type object');
            end

            w = struct();
            [w.main_header, w.header, w.detpar, w.data] = ldr.get_sqw('-legacy', 'pixel_page_size', pixel_page_size);
            obj = obj.init_from_loader_struct(w);
        end

        function obj = init_from_loader_struct(obj, data_struct)
            obj.main_header = data_struct.main_header;
            obj.header = data_struct.header;
            obj.detpar = data_struct.detpar;
            obj.data = data_struct.data;
        end
    end
end
