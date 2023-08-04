classdef boxClass
    % Class to test the functionality of object_lookup class methods
    % rand_ind and func_eval_ind.
    %
    % The methods are a little peculiar; they are designed to enable the output
    % of the object_lookup methods to be tested in an unambiguous manner. This
    % class in itself is pretty pointless.
    %
    % Forms one of a pair of classes along with boxArrayClass defined elsewhere
    
    properties
        position = [0;0;0]    % Column 3-vector giving location of box centre
        sides = [0;0;0]       % Column 3-vector of non-negative full widths
    end
    
    methods
        function obj = boxClass (position, sides)
            % Construct a scalar boxClass, or an array of boxClass objects
            %
            %   >> obj = boxClass (position, sides)
            %
            % Creates a three-dimensional cuboid centred on position with
            % specified full length of sides, or an array of such boxes.
            %
            % Default if no input arguments: a single box centred at
            % [0,0,0] with zero length sides
            %
            % Input:
            % ------
            %   position    Position vector (length = 3)
            %               OR
            %               Array size [3,nbox] where nbox is the number of
            %               boxes
            %
            %   sides       Sides (vector length 3)
            %               OR
            %               Array size [3,nbox] where nbox is the number of
            %               boxes
            
            if nargin==0
                return
                
            elseif nargin==2
                if numel(position)==3
                    position = position(:);
                elseif ~ismatrix(position) || isempty(position) || size(position,1)~=3
                    error('HERBERT:boxClass:invalid_argument', ...
                        'Check size of ''position'' argument')
                end
                
                nbox = size(position,2);
                if numel(sides)==3
                    sides = repmat(sides(:),[1,nbox]);
                elseif ~isequal(size(sides), [3, nbox])
                    error('HERBERT:boxClass:invalid_argument', ...
                        'Check size of ''sides'' argument matches that of ''position''')
                end
                
                if nbox>1
                    obj = repmat(boxClass,[1,nbox]);
                    for i=1:nbox
                        obj(i) = boxClass(position(:,i),sides(:,i));
                    end
                else
                    obj.position = position;
                    obj.sides = sides;
                end
                
            else
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check number of input arguments')
            end
        end
        
        %------------------------------------------------------------------
        function obj = set.position(obj, val)
            if isnumeric(val) && numel(val)==3
                obj.position = val(:);
            else
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check position is a 3-vector')
            end
        end
        
        function obj = set.sides(obj, val)
            if isnumeric(val) && numel(val)==3 && all(val(:)>=0)
                obj.sides = val(:);
            else
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check sides lengths form a 3-vector of non-negative values')
            end
        end
        
        %------------------------------------------------------------------
        function [x1col, x1row, x12] = rand_position (obj, sz, ...
                shift1col, shift1row, shift12)
            % Return random points from a single box, with that box optionally
            % shifted from the origin. There are three outputs, corresponding to
            % column vectors, row vectors and a 3x2 array. Each can have its own
            % independent shift of the box.
            %
            %   >> [x1col, x1row, x12] = rand_pos (obj, sz)
            %
            %   >> [x1col, x1row, x12] = rand_pos (obj, sz, ...
            %                               shift1col, shift1row, shift12)
            %
            % Input:
            % ------
            %   obj     Scalar instance of boxClass i.e. a single box
            %
            %   sz      Row vector giving the size of the array of random
            %           samples. Random samples (which may be arrays too)
            %           will be stacked according to this size array
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to random points held in x1col
            %               below
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift1row   Shift added to random points held in x1row
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift12     Shift added to random points held in x12
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            % Output:
            % -------
            %   x1col   Random points in the box - column vectors, stacked
            %           according to the size given by sz
            %
            %   x1row   Different random points in the box - row vectors,
            %           stacked according to the size given by sz
            %
            %   x12     Array size [3,2]: first column a random point,
            %           second for a box with half the side lengths but
            %           centred at the same point. Then stacked according
            %           to the size given by sz
            
            if ~isscalar(obj)
                error ('HERBERT:boxClass:invalid_argument', ...
                    'Must be a single box i.e. scalar instance of boxClass')
            end
            
            if ~(nargin==2 || nargin==5)
                error ('HERBERT:boxClass:invalid_argument', ...
                    'Check number of shift arguments')
            end
            
            if nargin==2
                % No shifts given; use optimised method
                [x1col, x1row, x12] = rand_position_single_shift (obj, sz);
                
            elseif numel(shift1col)==3 && numel(shift1row)==3 && numel(shift12)==3
                % Single vector given for each shift; use optimised method
                [x1col, x1row, x12] = rand_position_single_shift (obj, sz, ...
                    shift1col, shift1row, shift12);
                
            else
                s1col = shift_reshape (shift1col, sz);
                s1row = shift_reshape (shift1row, sz);
                s12 = shift_reshape (shift12, sz);
                
                npnt = prod(sz);
                x1col = NaN(3,npnt);
                x1row = NaN(3,npnt);
                x12 = NaN(3,2,npnt);
                for i=1:npnt
                    [x1col(:,i), x1row(:,i), x12(:,:,i)] = ...
                        rand_position_single_shift (obj, [1,1], ...
                        s1col(:,i), s1row(:,i), s12(:,i));
                end
                x1col = reshape (x1col, size_array_stack ([3,1], sz));
                x1row = reshape (x1row, size_array_stack ([1,3], sz));
                x12 = reshape (x12, size_array_stack ([3,2], sz));
            end
        end
        
        %------------------------------------------------------------------
        function [r1col, r1row, r12] = range (obj, varargin)
            % Return extent of the box, optionally further shifted
            %
            %   >> [r1col, r1row, r12] = range (obj)
            %
            %   >> [r1col, r1row, r12] = range (obj, sz)
            %
            %   >> [r1col, r1row, r12] = range (obj, shift1col, shift1row, shift12)
            %
            %   >> [r1col, r1row, r12] = range (obj, sz, shift1col, shift1row, shift12)
            %
            % Use to get the limits of the random numbers generated by
            % rand_pos.
            %
            % Input:
            % ------
            %   obj     Scalar instance of boxClass i.e. a single box
            %
            % Optional sz descriptor
            %   sz      Row vector giving the size of the array of random
            %           samples. Random samples (which may be arrays too)
            %           will be stacked according to this size array.
            %           Required if arrays of shift vectors are given, but
            %           not if single shift vectors.
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to random points held in x1col
            %               below
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift1row   Shift added to random points held in x1row
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift12     Shift added to random points held in x12
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            % Output:
            % -------
            %   r1col   Range of the x values along each axis for shift1col
            %           size = [3,2] where r1col(:,i) gives lower and upper
            %           limits along ith axis.
            %           Arrays size [3,2] for each shift are then stacked
            %           with size = sz.
            %
            %   r1row   Range when shift1row; same format and size==[3,2]
            %           Arrays size [3,2] for each shift are then stacked
            %           with size = sz.
            %
            %   r12     Array size(3,2,2), where r12(:,:,1) and r12(:,:,2)
            %           are respectively the lower and upper limits for the
            %           case of the box as given (r12(:,1,:)) and a box of
            %           half the extent along each axis (r12(:,2,:)).
            %           Arrays size [3,2,2] for each shift are then stacked
            %           with size = sz.
            
            if ~isscalar(obj)
                error('HERBERT:boxClass:invalid_argument', ...
                    'Must be a single box i.e. scalar instance of boxClass')
            end
            
            if numel(varargin)==0
                % No shifts given
                [r1col, r1row, r12] = range_single_shift (obj);
                
            elseif isequal(cellfun(@numel, varargin), [3 3 3])
                % Single vector given for each shift; use optimised method
                [r1col, r1row, r12] = range_single_shift (obj, ...
                    varargin{1}, varargin{2}, varargin{3});
                
            elseif numel(varargin)==1 || numel(varargin)==4
                % Either
                % - Size given, but no shift vectors (so all considered
                %   zero shift)
                % - A stack of vectors; check each is a single vector or has
                %   size consistent with sz
                % Return each shift as a 3 x npnts array
                sz = varargin{1};
                if numel(varargin)==1
                    s1col = shift_reshape ([0;0;0], sz);
                    s1row = shift_reshape ([0;0;0], sz);
                    s12 = shift_reshape ([0;0;0], sz);
                else
                    s1col = shift_reshape (varargin{2}, sz);
                    s1row = shift_reshape (varargin{3}, sz);
                    s12 = shift_reshape (varargin{4}, sz);
                end
                
                npnt = prod(sz);
                r1col = NaN(3,2,npnt);
                r1row = NaN(3,2,npnt);
                r12 = NaN(3,2,2,npnt);
                for i=1:npnt
                    [r1col(:,:,i), r1row(:,:,i), r12(:,:,:,i)] = ...
                        range_single_shift (obj, s1col(:,i), s1row(:,i), s12(:,i));
                end
                r1col = reshape (r1col, size_array_stack ([3,2], sz));
                r1row = reshape (r1row, size_array_stack ([3,2], sz));
                r12 = reshape (r12, size_array_stack ([3,2,2], sz));
                
            else
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check number and/or size of input arguments')
            end
            
        end
                
        %------------------------------------------------------------------
        function [ok, mess] = validate_points_in_box (obj, sz, x1col, x1row, x12, ...
                shift1col, shift1row, shift12)
            % Test if all points in a set lie inside a box, allowing for 
            % additional shift(s) of those points. Useful to test the output of
            % methods that emplot the boxClass method rand_position
            %
            %   >> [ok, mess] = validate_points_in_box (obj, sz, x1col, x1row, x12)
            %
            %   >> [ok, mess] = validate_points_in_box (obj, sz, x1col, x1row, x12, ...
            %                               shift1col, shift1row, shift12)
            %
            % Input:
            % ------
            %   obj     Scalar instance of boxClass i.e. a single box
            %
            %   sz      Row vector giving the size of the array of random
            %           samples. Random samples (which may be arrays too)
            %           will be stacked according to this size array.
            %           Required if arrays of shift vectors are given, but
            %           not if single shift vectors.
            %           This will be used to verify the size of the data
            %           arrays x1col, x1row, x12.
            %
            %   x1col   Random points in the box - column vectors, stacked
            %           according to the size given by sz
            %
            %   x1row   Different random points in the box - row vectors,
            %           stacked according to the size given by sz
            %
            %   x12     Array size [3,2]: first column a random point,
            %           second for a box with half the side lengths but
            %           centred at the same point. Then stacked according
            %           to the size given by sz
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to random points held in x1col
            %               below
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift1row   Shift added to random points held in x1row
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            %   shift12     Shift added to random points held in x12
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size = sz
            %
            % Output:
            % -------
            %   ok      True if all of the points lie within the shifted box
            %           False otherwise
            %
            %   mess    Empty if ok; message otherwise
            
            if ~isscalar(obj)
                error('HERBERT:boxClass:invalid_argument', ...
                    'Must be a single box i.e. scalar instance of boxClass')
            end
            
            % Confirm all data has correct size
            if ~isequal(size(x1col), size_array_stack ([3,1], sz))
                ok = false;
                mess = 'Size of x1col is inconsistent with other point data';
                return
            end
            if ~isequal(size(x1row), size_array_stack ([1,3], sz))
                ok = false;
                mess = 'Size of x1row is inconsistent with other point data';
                return
            end
            if ~isequal(size(x12), size_array_stack ([3,2], sz))
                ok = false;
                mess = 'Size of x12 is inconsistent with other point data';
                return
            end
            
            % Get ranges
            if nargin==5
                [r1col, r1row, r12] = range (obj, sz);
            else
                [r1col, r1row, r12] = range (obj, sz, shift1col, shift1row, shift12);
            end
            
            % Check points lie in expected ranges
            npnt = prod(sz);
            x1col_2D = reshape(x1col, [3,npnt]);
            x1row_2D = reshape(x1row, [3,npnt]);
            x12_2D = reshape(x12, [3,2,npnt]);
            
            r1col_lo_2D = reshape(r1col(:,1,:), [3,npnt]);
            r1col_hi_2D = reshape(r1col(:,2,:), [3,npnt]);
            r1row_lo_2D = reshape(r1row(:,1,:), [3,npnt]);
            r1row_hi_2D = reshape(r1row(:,2,:), [3,npnt]);
            r12_lo_2D = reshape(r12(:,:,1,:), [3,2,npnt]);
            r12_hi_2D = reshape(r12(:,:,2,:), [3,2,npnt]);
            
            ok = true;
            mess = '';
            small = 1e-12;
            if any(make_column(x1col_2D - r1col_lo_2D) < -small) || ...
                    any(make_column(x1col_2D - r1col_hi_2D) > small)
                ok = false;
                mess = 'One or more points in x1col out of range';
                return
            end
            if any(make_column(x1row_2D - r1row_lo_2D) < -small) || ...
                    any(make_column(x1row_2D - r1row_hi_2D) > small)
                ok = false;
                mess = 'One or more points in x1row out of range';
                return
            end
            if any(make_column(x12_2D - r12_lo_2D) < -small) || ...
                    any(make_column(x12_2D - r12_hi_2D) > small)
                ok = false;
                mess = 'One or more points in x12 out of range';
                return
            end
            
        end
                
        %------------------------------------------------------------------
    end
    
    methods (Access=private)
        function [x1col, x1row, x12] = rand_position_single_shift (obj, sz, ...
                shift1col, shift1row, shift12)
            % Return random points from the box, optionally further shifted
            %
            %   >> [x1col, x1row, x12] = rand_position_single_shift (obj, sz)
            %
            %   >> [x1col, x1row, x12] = rand_position_single_shift (obj, sz, ...
            %                               shift1col, shift1row, shift12)
            %
            % This is a helper routine for the method rand_position.
            %
            % Input:
            % ------
            %   obj     Scalar instance of boxClass i.e. a single box
            %
            %   sz      Row vector giving the size of the array of random
            %           samples. Random samples (which may be arrays too)
            %           will be stacked according to this size array
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to random points held in x1col
            %               below (3-vector)
            %
            %   shift1row   Shift added to random points held in x1row
            %               below (3-vector)
            %
            %   shift12     Shift added to random points held in x12
            %               below (3-vector)
            %
            % Output:
            % -------
            %   x1col   Random points in the box - column vectors, stacked
            %           according to the size given by sz
            %
            %   x1row   Different random points in the box - row vectors,
            %           stacked according to the size given by sz
            %
            %   x12     Array size [3,2]: first column a random point,
            %           second for a box with half the side lengths but
            %           centred at the same point. Then stacked according
            %           to the size given by sz
            
            if ~isscalar(obj)
                error('HERBERT:boxClass:invalid_argument', ...
                    'Must be a single box i.e. scalar instance of boxClass')
            end
            
            if nargin==2
                shift1col = [0;0;0];
                shift1row = [0;0;0];
                shift12 = [0;0;0];
            elseif nargin~=5
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check number of arguments')
            end
            
            shift = obj.position + shift1col(:);
            x1col = shift + obj.sides .* (2*rand(3,prod(sz)) - 1) / 2;
            szout = size_array_stack ([3,1], sz);
            x1col = reshape(x1col, szout);
            
            shift = obj.position + shift1row(:);
            x1row = shift + obj.sides .* (2*rand(3,prod(sz)) - 1) / 2;
            szout = size_array_stack ([1,3], sz);
            x1row = reshape(x1row, szout);
            
            shift = repmat(obj.position + shift12(:), [2,1]);
            x12 = shift + [obj.sides; obj.sides/2] .* (2*rand(6,prod(sz)) - 1) / 2;
            szout = size_array_stack ([3,2], sz);
            x12 = reshape(x12, szout);
            
        end
        
        %------------------------------------------------------------------
        function [r1col, r1row, r12] = range_single_shift (obj, ...
                shift1col, shift1row, shift12)
            % Return extent of the box, optionally further shifted
            %
            %   >> [r1col, r1row, r12] = range_single_shift (obj)
            %
            %   >> [r1col, r1row, r12] = range_single_shift (obj, ...
            %                               shift1col, shift1row, shift12)
            %
            % This is a helper routine for the method range.
            %
            %
            % Input:
            % ------
            %   obj         Scalar instance of boxClass i.e. a single box
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to box (3-vector)
            %
            %   shift1row   Different shift (3-vector)
            %
            %   shift12     Third shift (3-vector)
            %
            % Output:
            % -------
            %   r1col   Range of the x values along each axis for shift1col
            %           size = [3,2] where r1col(i,:) gives lower and upper
            %           limits along ith axis
            %
            %   r1row   Range when shift1row; same format and size==[3,2]
            %
            %   r12     Array size(3,2,2), where r12(:,:,1) and r12(:,:,2)
            %           are respectively the lower and upper limits for the
            %           case of the box as given (r12(:,1,:)) and a box of
            %           half the extent along each axis (r12(:,2,:)).
            
            if ~isscalar(obj)
                error('HERBERT:boxClass:invalid_argument', ...
                    'Must be a single box i.e. scalar instance of boxClass')
            end
            
            if nargin==1
                shift1col = [0;0;0];
                shift1row = [0;0;0];
                shift12 = [0;0;0];
            elseif nargin~=4
                error('HERBERT:boxClass:invalid_argument', ...
                    'Check number of arguments')
            end
            
            shift = obj.position + shift1col(:);
            r1col = shift + obj.sides*[-0.5,0.5];
            
            shift = obj.position + shift1row(:);
            r1row = shift + obj.sides*[-0.5,0.5];
            
            shift = obj.position + [shift12(:),shift12(:)];
            lower = shift + obj.sides*[-0.5,-0.25];
            upper = shift + obj.sides*[0.5,0.25];
            r12 = cat(3,lower,upper);
            
        end
        
    end
    
end

%------------------------------------------------------------------
function shift_out = shift_reshape (shift, sz_stack)
% Checks validity of shift argument
%
%   >> shift_out = shift_reshape (shift, sz_stack)
%
% Input:
% ------
% shift     One of:
%           - a row or column 3-vector
%           - a stack size==sz_stack of row or column 3-vectors
%
% sz_stack  Matlab size of stacking array.
%
% Output:
% -------
% shift_out Stack of column 3-vectors, size == [3, prod(sz_stack)]

if numel(shift)==3
    shift_out = repmat(shift(:), [1,prod(sz_stack)]);
else
    sz_full_col = size_array_stack ([3,1], sz_stack);
    sz_full_row = size_array_stack ([1,3], sz_stack);
    if isequal(size(shift), sz_full_col) || isequal(size(shift), sz_full_row)
        shift_out = reshape(shift, [3,prod(sz_stack)]);
    else
        error('HERBERT:boxClass:invalid_argument', ...
            'Invalid shape of array of shifts')
    end
end

end
