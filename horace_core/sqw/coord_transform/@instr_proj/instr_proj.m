classdef instr_proj<aProjection
    %  Class defines coordinate transformations necessary to convert the
    %  results of neutron experiments from the physical space of inelastic
    %  neutron instrument (instrument frame), to orthogonal reciprocal
    %  space related to lattice (Crystal Cartesian)
    %
    %  Defines coordinate transformations, used by gen_sqw when building
    %  Horace sqw files
    %
    %
    % Input accepting a structure:
    %   >> proj = instr_proj(proj_struct)
    %             where proj_struct is the
    %             structure, containing any fields, with names, corresponding
    %             to any public fields of the instr_proj class.
    %
    % Argument input:
    %   >> proj = instr_proj(lattice,efix,emode)
    %   plus any optional argument, representing public property of the
    %   instr_proj class and presented as key-value pair.
    %
    %
    % Input:
    % ------
    % arguments requested by constructor:
    %   lattice -- initialized version of oriented lattice class defining
    %          the crystal lattice and its orientation with relatively to
    %          the beam.
    %   efix   incident energy for direct instrument and crystal analyser
    %          energy(ies) for indirect. Ignored for elastic
    %   emode  -- the operational mode of instrument (1-direct, 2-indirect,
    %          0 - elastic)
    %
    %
    % The optional arguments control goniometer settings, used to fix the
    % rotation in plain [u,v] by psi if initial state deviates from u||ki,
    % plus by labels etc.
    %
    % The empty constructor builds ortho_instr_proj with u=[1,0,0],v=[0,1,0]
    % and psi=0;
    %
    %
    properties(Dependent)
        efix % incident energy for direct instrument or crystal analyser(s)
        %      energy(ies) for indirect. Ignored for elastic
        %
        emode % type of instrument (1-direct,2-indirect,0 - elastic)
        %  Angle of axis of small goniometer arc w.r.t. notional u (deg)  [Default=0]
        %
        lattice; % accessor to the oriented lattice, which holds all properties above
    end

    properties(Access=protected)
        lattice_ = oriented_lattice();
        emode_ = 1;
        efix_ = 0;
    end

    methods
        function proj=instr_proj(varargin)
            % The construct
            % Optional input parameters:
            % lattice -- initialized instance of oriented lattice
            % efix    -- incident energy or array of incident energies
            % emode   -- the instrument operational mode
            %
            proj = proj@aProjection();
            proj.label = {'Q_x','Q_y','Q_z','dE'};
            if nargin>0 % initialize defaults, which describe unit transformation from
                proj = proj.init(varargin{:});
            end
        end
        %
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            % Here one can provide lattice,efix and emode values as
            % positional parameters or as key-value pairs
            %
            if nargin == 0
                return
            end
            input_fields_names = instr_proj.fields_to_save_;
            if nargin >=4
                obj.emode = varargin{3}; % set emode first for case when
                % emode == 0 and efix may be 0 or negative, as efix is
                % ignored in emode == 0
            end
            % define possible key-value parameters of the constructor,
            % using standard serializable contsturctor form.
            validators = {@(x)isa(x,'oriented_lattice')};
            [obj,remains] = set_positional_and_key_val_arguments(obj,...
                input_fields_names,validators,varargin{:});
            if ~isempty(remains)
                error('HORACE:instr_proj:invalid_argument',...
                    'provided unrecognised input(s) for instr_proj initialization: %s',...
                    evalc('disp(remains)'));
            end
        end
        %-----------------------------------------------------------------
        %-----------------------------------------------------------------
        function efix = get.efix(obj)
            efix = obj.efix_;
        end
        function obj = set.efix(obj,val)
            if any(val <= 0) && obj.emode_ ~=0
                error('HORACE:instr_proj:invalid_argument',...
                    'efix can not be negative')
            end
            obj.efix_ = val(:)';
        end

        %
        function emd = get.emode(obj)
            emd  = obj.emode_;
        end
        function obj = set.emode(obj,val)
            obj = check_and_set_emode_(obj,val);
        end
        %
        function lat = get.lattice(obj)
            lat = obj.lattice_;
        end
        function obj = set.lattice(obj,val)
            if ~isa(val,'oriented_lattice')
                error('HORACE:instr_proj:invalid_argument',...
                    'the lattice for instrument projection should be instance of "oriented_lattice" class')
            end
            obj.lattice_ = val;
            % Redefine generic projection lattice properties
            obj.alatt = val.alatt;
            obj.angdeg = val.angdeg;
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        % and overloads for specific methods
        %------------------------------------------------------------------
        function pix_coord = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in instrument frame into
            % into Crystal Cartesian coordinate system.
            %
            % Input:
            % pix_data -- rundatah object containing information about
            %             detectors positions and the signal received by
            %             detectors during the run as function of energy
            %             transfer
            % Returns:
            % pix_coord -- 4D array of pixel coordinates containing pixel
            %              positions in crystal  Cartesian coordinate system
            %
            pix_coord = transform_pix_to_img_(obj,pix_data,varargin{:});
        end
        %
        function pix_cc = transform_img_to_pix(obj,pix_hkl,varargin)
            % Transform pixels expressed in image coordinate coordinate systems
            % into crystal Cartesian coordinate system
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            % Returns
            % pix_cc -- pixels expressed in Crystal Cartesian coordinate
            %            system
            %
            error('HORACE:instr_proj:not_implemented',...
                'transformation from Crystal Cartesian to instrument coordinate frame is not yet implemented')
        end
        function [pix,det0,axes] = convert_rundata_to_pix(obj,run_data,varargin)
            % convert data provided as
            [pix,det0,axes]  = convert_rundata_to_pix_(obj,run_data,varargin{:});
        end
        function [npix,s,e,pix_ok,unique_runid,det0,axes] = bin_pixels(obj,axes,run_data,varargin)
            % Convert pixels into the coordinate system, defined by the
            % projection and bin them into the coordinate system, defined
            % by the axes block, specified as input.
            [pix,det0,axes]  = obj.convert_rundata_to_pix(run_data,axes);
            [npix,s,e,pix_ok,unique_runid] = ...
                bin_pixels@aProjection(obj,axes,pix,varargin{:});
        end
        %
        function ax_bl = get_proj_axes_block(~,ranges,bin_numbers)
            % return the axes block, corresponding to this projection class.
            %
            % According to its operations, instrument projection generate
            % axes_block directly from data range and number of bin in each
            % direction
            ax_bl = axes_block(4);
            % set up range and number of bins for the selected axes block
            ax_bl.img_range = ranges;
            ax_bl.nbins_all_dims = bin_numbers;
            % other parameters
            ax_bl.ulen  = [1,1,1,1];
            % TODO, delete this, mutate axes_block
            ax_bl.axis_caption=an_axis_caption();
            ax_bl.label = {'Q_\zeta','Q_\xi','Q_\eta','E'};

        end
        %
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjection(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
        end
    end
    %----------------------------------------------------------------------
    properties(Constant, Access=private)
        fields_to_save_ = {'lattice','efix','emode'}
    end
    %----------------------------------------------------------------------
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = instr_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
    methods(Access = protected)
        function  alat = get_alatt_(obj)
            % get lattice from oriented lattice property
            alat  = obj.lattice.alatt;
        end
        function  angdeg = get_angdeg_(obj)
            % get lattice angles from oriented lattice property
            angdeg  = obj.lattice.angdeg;
        end

        %
        function obj = check_and_set_targ_proj(obj,~)
            error('HORACE:inst_proj:not_implemented',...
                'cuts in instrument frame are not yet implemented')
        end
        function proj = get_target_proj(~)
            proj = ortho_proj();
        end

    end
end