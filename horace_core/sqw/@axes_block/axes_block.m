classdef axes_block
    % The class contains information, related to coordinates of sqw or dnd
    % object
    %
    %  This is the block of axis in Cartesian coordinate system.
    
    properties
        title   =''   % Title of sqw data structure
        filename=''   % Name of sqw file that is being read, excluding path
        filepath=''   % Path to sqw file that is being read, including terminating file separator
        
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
        axis_caption=an_axis_caption(); %  Reference to class, which define axis captions. TODO: delete this
        %
        %TODO: think about best place to put this property
        %  it may belong to projection but should be here if used in
        %  plotting. Should non-orthogonal be just different axes_block?
        nonorthogonal = false % if the coordinate system is non-orthogonal.
    end
    methods (Static)
        % Create bin boundaries for integration and plot axes from requested limits and step sizes
        [iax, iint, pax, p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin, pin, nbin);
        
    end
    
    
    properties(Constant,Access=private)
        % fields which fully represent the state of the class and allow to
        % recover it through public interface
        fields_to_save_ = {'title','filename','filepath',...
            'ulen','ulabel','iax','iint','pax',...
            'p','dax','nonorthogonal'};
    end
    
    
    methods
        function flds = indepFields(~)
            % get independent fields, which fully define the state of a
            % serializable object.
            flds = axes_block.fields_to_save_;
        end
        
        % return 3 q-axis in the order they mark the dnd object
        % regardless of the integration along some qxis
        % TODO: probably should be removed
        [q1,q2,q3] = get_q_axes(obj);
        % return binning range of existing data object
        range = get_bin_range(obj);
        % find the coordinates along each of the axes of the smallest cuboid
        % that contains bins with non-zero values of contributing pixels.
        [val, n] = data_bin_limits (din);
        
        % build new axes_block object from the binning parameters, provided
        % as input. If some input binning parameters are missing, the
        % defauls are taken from existing axes_block object.
        obj = build_from_input_binning(obj,targ_proj,img_db_range,source_proj,pin);
        
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
        
        function [obj,remain] = from_struct(obj,inputs)
            % set data from external structure
            %
            % return the part of the external structure, which is not
            % related to the current class data
            [obj,remain] = from_struct_(obj,inputs);
        end
        function str = struct(obj)
            flds = obj.fields_to_save_;
            str = struct();
            for i=1:numel(flds)
                str.(flds{i}) = obj.(flds{i});
            end
        end
    end
end

