classdef axes_block < serializable
    % The class contains information, related to coordinates of sqw or dnd
    % object
    %
    %  This is the block of axis in Cartesian coordinate system.
    
    properties
        title   =''   % Title of sqw data structure
        filename=''   % Name of sqw file that is being read, excluding path. Used in titles
        filepath=''   % Path to sqw file that is being read, including terminating file separator.
        %               Used in titles
        
        %
        ulen=[1,1,1,1]      %Length of projection axes vectors in Ang^-1 or meV [row vector]
        ulabel={'Q_h','Q_k','Q_l','En'}  %Labels of the projection axes [1x4 cell array of character strings]
        iax=1:4;          %Index of integration axes into the projection axes  [row vector]
        %                  Always in increasing numerical order
        %                  e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
        iint=zeros(2,4);   %Integration range along each of the integration axes. [iint(2,length(iax))]
        %                   e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
        pax=zeros(1,0);   %Index of plot axes into the projection axes  [row vector]
        %                Always in increasing numerical order
        %                e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
        %                2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
        p=cell(1,0);  %  Cell array containing bin boundaries along the plot axes [column vectors]
        %                i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
        dax=zeros(1,0)    %Index into data.pax of the axes for display purposes. For example we may have
        %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
        %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
        %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
        %                  be reordered [row vector]
        axis_caption=an_axis_caption(); %  Reference to class, which define axis captions. TODO: delete this, mutate axes_block
        %
        %TODO: think about best place to put this property
        %  it may belong to projection but should be here if used in
        %  plotting. Should non-orthogonal be just different axes_block?
        nonorthogonal = false % if the coordinate system is non-orthogonal.
    end
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it state by setting properties through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'ulen','ulabel','iax','iint','pax',...
            'p','dax','nonorthogonal'};
    end
    
    methods (Static)
        % build new axes_block object from the binning parameters, provided
        % as input. If some input binning parameters are missing, the
        % defaults are taken from the given image range which should be
        % properly prepared
        [obj,targ_img_db_range] = build_from_input_binning(cur_img_range_and_steps,pbin);
        % Create bin boundaries for integration and plot axes from requested limits and step sizes
        [iax, iint, pax, p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin, pin, nbin);
        
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = axes_block();
            obj = loadobj@serializable(S,obj);
        end
        function img_db_range = calc_img_db_range(ax_data)
            % function used to retrieve 4D range used for rebinning pixels
            % from old style sqw objects, where this range was not stored
            % directly as it may become incorrect after some
            % transformations.
            %
            % Returns:
            % img_db_range  -- the estimate for the image range, used to
            %                  build the grid used as keys to get the pixels,
            %                  contributed into the image
            %
            % Should not be used directly, only for compatibility with old
            % data formats. New sqw object should maintain correct
            % img_db_range during all operations
            %
            % Inputs: either data_sqw_dnd instance or a structure
            % containing:
            % The relevant data structure used as source of image range is as follows:
            %
            %   ds.iax        Index of integration axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 2D, data.iax=[1,3] means summation has been performed along u1 and u3 axes
            %   ds.iint       Integration range along each of the integration axes. [iint(2,length(iax))]
            %                       e.g. in 2D case above, is the matrix vector [u1_lo, u3_lo; u1_hi, u3_hi]
            %   ds.pax        Index of plot axes into the projection axes  [row vector]
            %                  Always in increasing numerical order
            %                       e.g. if data is 3D, data.pax=[1,2,4] means u1, u2, u4 axes are x,y,z in any plotting
            %                                       2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
            %   ds.p          Cell array containing bin boundaries along the plot axes [column vectors]
            %                       i.e. row cell array{data.p{1}, data.p{2} ...} (for as many plot axes as given by length of data.pax)
            %   ds.dax        Index into data.pax of the axes for display purposes. For example we may have
            %                  data.pax=[1,3,4] and data.dax=[3,1,2] This means that the first plot axis is data.pax(3)=4,
            %                  the second is data.pax(1)=1, the third is data.pax(2)=3. The reason for data.dax is to allow
            %                  the display axes to be permuted but without the contents of the fields p, s,..pix needing to
            %
            
            img_db_range = zeros(2,4);
            img_db_range(:,ax_data.iax) = ax_data.iint;
            if numel(ax_data.iax)>0
                % let's assume that newly generated sqw file has
                % 4 dimensions and cuts have at least one direction
                % integrated.
                newly_generated = false;
            else
                newly_generated = true;
            end
            
            npax = numel(ax_data.p);
            pax_range = zeros(2,npax);
            for i=1:npax
                if newly_generated
                    % newly generated old sqw files have axis extended to
                    % range of pixel data
                    pax_range(:,i) = [ax_data.p{i}(1);...
                        ax_data.p{i}(end)];
                    
                else
                    %   cuts axis rage is extended by half-bin
                    %   wrt to actual pixel rebinning range
                    h_bin_width = 0.5*abs(ax_data.p{i}(2)-ax_data.p{i}(1));
                    pax_range(:,i) = [ax_data.p{i}(1)+h_bin_width,...
                        ax_data.p{i}(end)-h_bin_width];
                    
                end
            end
            img_db_range(:,ax_data.pax) = pax_range;
        end
    end
    
    methods
        function obj = axes_block(varargin)
            % constructor
            %
            %>>obj = axes_block() % return empty axis block
            %>>obj = axes_block(ndim) % return unit block with ndim
            %                           dimensions
            %>>obj = axes_block(p1,p2,p3,p4) % build axis block from axis
            %                                  arrays
            %>>obj = axes_block(pbin1,pbin2,pbin3,pbin4) % build axis block
            %                                       from binning parameters
            %
            if nargin==0
                return;
            end
            obj = obj.init(varargin{:});
        end
        %
        % Find number of dimensions and extent along each dimension of
        % the signal arrays.
        [nd,sz] = data_dims(data);
        % return 3 q-axis in the order they mark the dnd object
        % regardless of the integration along some axis
        % TODO: probably should be removed
        [q1,q2,q3] = get_q_axes(obj);
        %
        % return binning range of existing data object, so that cut without
        % projection, performed within this range would return the same cut
        % as the original object
        range = get_cut_range(obj);
        %
        % find the coordinates along each of the axes of the smallest cuboid
        % that contains bins with non-zero values of contributing pixels.
        [val, n] = data_bin_limits (din);
        %

        function [cube_coord,step] = get_axes_scales(obj)
            % Return 4D cube, describing the minimal grid cell of the axes block            
            [cube_coord,step] = get_axes_scales_(obj);
        end
        function range = get_binning_range(obj)
            % return binning range, defined by current projection and
            % integration axes ranges
            %
            % Returns:
            % range  -- 2x4 array of min/max values of the axes grid,
            %           described by the axes_block and used for the
            %           pixels binning.
            range = get_binning_range_(obj);
        end
        
        function [npix,s,e,pix] = bin_pixels(obj,coord,varargin)
            % bin and distribute data expressed in the coordinate system
            % described by this axes block over the current lattice
            % Usage:
            % >>npix = obj.bin_pixels(coord);
            % >>[npix,s,e] = obj.bin_pixels(coord,signal,error);
            % >>[npix,s,e,pix] = bin_pixels(obj,coord,signal,error,pix_obj)
            % Where
            % Inputs:
            % coord   -- [4,npix] array of pixels coordinates to bin
            % signal  -- npix array of pixel signal
            % error   -- npix array of pixels error
            % pix_obj -- PixelData or pixel file access object, providing
            %            the access to the full pixels information
            % Returns:
            % npix    -- the array, containing the numbers of pixels
            %            contributing into each grid cell
            % s       -- empty if input signal and error are absent or
            %            array, containing the accumulated signal for each 
            %            grid bin
            % e       -- empty if input signal and error are absent or
            %            array, containing the accumulated error for each 
            %            grid bin
            % pix     -- 
            [npix,s,e,pix] = bin_pixels_(obj,coord,varargin{:});            
        end
        
        function [nodes,varargout] = get_bin_nodes(obj,varargin)
            % returns [4,nBins] or [3,nBins] array of points, where each point
            % coordinate is a node of the grid, formed by axes_block axes.
            %
            % Inputs:
            % varargin{1} -- if present, contains the nodes of 4D cube, or
            %                this cube min/max nodes coordinates, describing
            %                the  characteristic scale of the grid,
            %                the generated grid should fit to.
            if nargout == 2
                [nodes,en_axis] = calc_bin_nodes_(obj,varargin{:});
                varargout{1} = en_axis;
            else
                nodes = calc_bin_nodes_(obj,varargin{:},'4D');
            end
        end
        %
        function range = get_default_binning_range(obj,img_db_range,...
                cur_proj,new_proj)
            % get the default binning range to use in cut, defined by new
            % projection, and extrapolated from existing binning range
            %
            % If new projection is not aligned with the old projection, the new
            % projection binning is copied from old projection binning according to
            % axis, i.e. if axis 1 of cur_proj had 10 bins, axis 1 of target proj would
            % have 10 bins, etc.
            
            % Inputs:
            % obj      - current instance of the axes block
            % img_db_range -- the range pixels are binned on and the current binning is
            %            applied
            
            % cur_proj - the projection, current block is defined for
            % new_proj - the projection, for which the requested range should
            %            be defined
            % Output:
            % range    - 4-element cellarray of ranges, containing current
            %            binning range expressed in the coordinate system,
            %            defined by the new projection
            range  = get_default_binning_range_(obj,img_db_range,cur_proj,new_proj);
        end
        
        %
        function [obj,uoffset,remains] = init(obj,varargin)
            % initialize object with axis parameters.
            %
            % The parameters are defined as in constructor.
            % Returns:
            % obj     -- initialized by inputs axis_block object
            % uoffset -- the offset for axis box from the origin of the
            %            coordinate system
            % remains -- the arguments, not used in initialization if any
            %            were provided as input
            %
            [obj,uoffset,remains] = init_(obj,varargin{:});
        end
        function flds = indepFields(~)
            % get independent fields, which fully define the state of a
            % serializable object.
            flds = axes_block.fields_to_save_;
        end
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
    end
end
