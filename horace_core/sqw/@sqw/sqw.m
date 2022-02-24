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
        runid_map % the map which connects header number with run_id
        header
        detpar
        % CMDEV: data now a dependent property, below
    end

    properties(Dependent)
        npixels % common with loaders interface to pix.num_pixels property
                % used for organizing common interface to pixel data
        data;   % 
    end

    methods (Access = protected)
        wout = sqw_eval_pix_(w, sqwfunc, ave_pix, pars, outfilecell, i);
    end

    methods
        wout = sigvar(w);
        w = sigvar_set(win, sigvar_obj);
        sz = sigvar_size(w);
        %[sel,ok,mess] = mask_points (win, varargin);
        varargout = multifit (varargin);

        varargout = tobyfit (varargin);
        [wout,state_out,store_out]=tobyfit_DGdisk_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, indx);
        [wout,state_out,store_out]=tobyfit_DGfermi_resconv(win,caller,state_in,store_in,...
            sqwfunc,pars,lookup,mc_contributions,mc_points,xtal,modshape);
        [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx);
        [ok,mess,varargout] = parse_pixel_indicies (win,indx,iw);
        wout=combine_sqw(w1,w2);

        wout=rebin_sqw(win,varargin);
        wout=symmetrise_sqw(win,v1,v2,v3);
        [ok,mess,w1tot,w2tot]=is_cut_equal(f1,f2,varargin);
        wtot=combine_cuts(w);
        wout=recompute_bin_data_tester(sqw_obj);
        wout = dnd (win);
        [header_ave, ebins_all_same]=header_average(header);
        [alatt,angdeg,ok,mess] = lattice_parameters(win);
        [wout, pars_out] = refine_crystal_strip_pars (win, xtal, pars_in);
        img_range = recompute_img_range(w);

        wout = section (win,varargin);
        [sqw_type, ndims, nfiles, filename, mess,ld] = is_sqw_type_file(w,infile);
        [d, mess] = make_sqw_from_data(varargin);
        varargout = head (varargin);
        d=spe(w);
        %{
        %[deps,eps_lo,eps_hi,ne]=energy_transfer_info(header);
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
                obj = obj.init_from_file_(args.filename, args.pixel_page_size);

                % iii) struct or data loader
            elseif ~isempty(args.data_struct)
                if isa(args.data_struct,'dnd_file_interface')
                    args.data_struct = obj.get_loader_struct_(...
                        args.data_struct,args.pixel_page_size);
                    if isempty(args.data_struct.runid_map)
                        args.data_struct.runid_map = recalculate_runid_map_( args.data_struct.header);
                    end
                end
                obj = obj.init_from_loader_struct_(args.data_struct);
            end


        end

        % Public getters/setters expose all wrapped data attributes
        function val = get.data(obj)
            val = obj.data_;
        end
        function obj = set.data(obj, d)
            %if isa(d,'data_sqw_dnd') || isempty(d)
            obj.data_ = d;
            %else
            %    error('HORACE:sqw:invalid_argument',...
            %        'Only data_sqw_dnd class or empty value may be used as data value. Trying to set up: %s',...
            %        class(d))
            %end
        end
        %        function  save_xye(obj,varargin)
        %            %TODO: Enable this when doing #730
        %            % save data in xye format
        %            save_xye@DnDBase(obj.data,varargin{:});
        %        end
        function npix = get.npixels(obj)
            if isempty(obj.data_)
                npix = 'undefined';
            else
                pix = obj.data_.pix;
                if isempty(pix)
                    npix = 0;
                else
                    npix = pix.num_pixels;
                end
            end
        end

    end

    methods(Static)
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
            if isa(S,'sqw')
                obj = S;
                if isempty(obj.runid_map)
                    obj.runid_map = recalculate_runid_map_(S.header);
                end
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

        wout = sqw_eval_(wout, sqwfunc, ave_pix, all_bins, pars);
    end

    methods(Static, Access = private)
        % Signatures of private functions declared in files
        sqw_struct = make_sqw(ndims);
        detpar_struct = make_sqw_detpar();
        header = make_sqw_header();
        main_header = make_sqw_main_header();

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
            parser.addOptional('input', [], @(x) (isa(x, 'SQWDnDBase') || ...
                is_string(x) || ...
                isa(x,'dnd_file_interface') || ...
                isstruct(x)));
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
            elseif (isstruct(input)||isa(input,'dnd_file_interface')) && ~isempty(input)
                args.data_struct = input;
            else
                % create struct holding default instance
                args.data_struct = make_sqw(0);
            end
        end
    end

    methods(Access = 'private')
        function obj = init_from_file_(obj, in_filename, pixel_page_size)
            % Parse SQW from file
            %
            % An error is raised if the data file is identified not a SQW object
            ldr = sqw_formats_factory.instance().get_loader(in_filename);
            if ~strcmpi(ldr.data_type, 'a') % not a valid sqw-type structure
                error('SQW:sqw', 'Data file does not contain valid sqw-type object');
            end
            lds = obj.get_loader_struct_(ldr,pixel_page_size);
            obj = obj.init_from_loader_struct_(lds);
        end
        function ld_str = get_loader_struct_(~,ldr,pixel_page_size)
            % load sqw structure, using file loader
            ld_str = struct();
            [ld_str.main_header, ld_str.header, ld_str.detpar,...
                ld_str.data,ld_str.runid_map] = ...
                ldr.get_sqw('-legacy', 'pixel_page_size', pixel_page_size);
        end
        function obj = init_from_loader_struct_(obj, data_struct)
            % initialize object contents using structure, obtained from
            % file loader
            obj.main_header = data_struct.main_header;
            obj.header = data_struct.header;
            obj.detpar = data_struct.detpar;
            obj.data = data_struct.data;
            if isfield(data_struct,'runid_map')
                obj.runid_map = data_struct.runid_map;
            else % calculate runid map from header file names
                obj.runid_map = recalculate_runid_map_(data_struct.header);
            end
        end
    end
end
