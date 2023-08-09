classdef boxArrayClass
    % Class to test the functionality of object_lookup class methods
    % rand_ind and func_eval_ind for objects with inner arrays
    %
    % Forms a pair with boxArrayClass defined elsewhere
    
    properties
        box     % Array of boxClass objects
    end
    
    properties (Dependent)
        nbox    % Number of boxes
    end
    
    methods
        function obj = boxArrayClass (position, sides)
            % Construct an instance of boxArrayClass
            %
            %   >> obj = boxArrayClass (position, sides)
            %
            % Creates a single object that in general describes an array of
            % three-dimensional cuboids.
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
                obj.box = boxClass ();
                
            elseif nargin==2
                if numel(position)==3
                    position = position(:);
                elseif ~ismatrix(position) || isempty(position) || size(position,1)~=3
                    error('HERBERT:boxArrayClass:invalid_argument', ...
                        'Check size of ''position'' argument')
                end
                
                nbox = size(position,2);
                if numel(sides)==3
                    sides = repmat(sides(:),[1,nbox]);
                elseif ~isequal(size(sides), [3, nbox])
                    error('HERBERT:boxArrayClass:invalid_argument', ...
                        'Check size of ''sides'' argument matches that of ''position''')
                end
                
                box = repmat(boxClass,[1,nbox]);
                for i=1:nbox
                    box(i) = boxClass(position(:,i),sides(:,i));
                end
                obj.box = box;
                
            else
                error('HERBERT:boxArrayClass:invalid_argument', ...
                    'Check number of input arguments')
            end
        end
        
        %------------------------------------------------------------------
        function val = get.nbox(obj)
            val = numel(obj.box);
        end
        
        %------------------------------------------------------------------
        function [x1col, x1row, x12] = rand_elmts_position (obj, ielmts, ...
                shift1col, shift1row, shift12)
            % Return random points from a single box, optionally further shifted
            %
            %   >> [x1col, x1row, x12] = rand_elmts_position (obj, ielmts)
            %
            %   >> [x1col, x1row, x12] = rand_elmts_position (obj, ielmts, ...
            %                               shift1col, shift1row, shift12)
            %
            % Returns one random point for each of the internal boxes
            % indicated by the index array elmts.
            %
            % Input:
            % ------
            %   obj     Single instance of a boxArrayClass object
            %
            %   ielmts  Indices of internal elements of the object
            %
            % Optional shifts (give either none or all three):
            %
            %   shift1col   Shift added to random points held in x1col
            %               below
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size==size(ielmts)
            %
            %   shift1row   Shift added to random points held in x1row
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size==size(ielmts)
            %
            %   shift12     Shift added to random points held in x12
            %               below (3-vector)
            %               - a single 3-vector:
            %               - a stack of 3-vectors, stacked with size==size(ielmts)
            %
            % Output:
            % -------
            %   x1col   Random points in the box - column vectors, stacked
            %           according to the size given by size(ielmts)
            %
            %   x1row   Different random points in the box - row vectors,
            %           stacked according to the size given by size(ielmts)
            %
            %   x12     Array size [3,2]: first column a random point,
            %           second for a box with half the side lengths but
            %           centred at the same point. Then stacked according
            %           to the size given by size(ielmts)
            
            if ~isscalar(obj)
                error('HERBERT:boxArrayClass:invalid_argument', ...
                    'Must be a scalar instance of boxArrayClass')
            end
            
            if nargin==2
                shift1col = [0;0;0];
                shift1row = [0;0;0];
                shift12 = [0;0;0];
                
            elseif nargin~=5
                error('HERBERT:boxArrayClass:invalid_argument', ...
                    'Check number of shift arguments')
            end
            
            npnt = numel(ielmts);
            sz = size(ielmts);
            
            s1col = shift_reshape (shift1col, sz);
            s1row = shift_reshape (shift1row, sz);
            s12 = shift_reshape (shift12, sz);
            
            x1col = NaN(3,npnt);
            x1row = NaN(3,npnt);
            x12 = NaN(3,2,npnt);
            for i=1:npnt
                [x1col(:,i), x1row(:,i), x12(:,:,i)] = ...
                    rand_position (obj.box(ielmts(i)), [1,1], s1col(:,i), s1row(:,i), s12(:,i));
            end
            x1col = reshape (x1col, size_array_stack ([3,1], sz));
            x1row = reshape (x1row, size_array_stack ([1,3], sz));
            x12 = reshape (x12, size_array_stack ([3,2], sz));
        end
        
        %--------------------------------------------------------------------------
        function [ok, mess] = validate_points_in_boxArray (obj, ielmts, ...
                x1col, x1row, x12, shift1col, shift1row, shift12)
            % Test points as could be generated by the method rand_elmts_position
            % lie inside the boxArray object, with optional shifts.
            %
            %   >> [ok, mess] = validate_points_in_boxArray (obj, x1col, x1row, x12)
            %
            %   >> [ok, mess] = validate_points_in_boxArray (obj, x1col, x1row, x12, ...
            %                               shift1col, shift1row, shift12)
            %
            % Input:
            % ------
            %   obj     Scalar instance of boxClass i.e. a single box
            %
            %   ielmts  Indices of internal elements of the object
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
                error('HERBERT:boxArrayClass:invalid_argument', ...
                    'Must be a scalar instance of boxArrayClass')
            end
            
            % Determine size of stack
            sz = size(ielmts);
            
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
            
            if nargin==5
                s1col = shift_reshape ([0;0;0], sz);
                s1row = shift_reshape ([0;0;0], sz);
                s12 = shift_reshape ([0;0;0], sz);
            else
                s1col = shift_reshape (shift1col, sz);
                s1row = shift_reshape (shift1row, sz);
                s12 = shift_reshape (shift12, sz);
            end
            
            % Perform checks
            npnt = prod(sz);
            x1col_2D = reshape(x1col,[3,npnt]);
            x1row_2D = reshape(x1row,[3,npnt]);
            x12_3D = reshape(x12,[3,2,npnt]);

            for i=1:npnt
                [ok, mess] = validate_points_in_box (obj.box(ielmts(i)), ...
                    [1,1], x1col_2D(:,i), x1row_2D(:,i)', x12_3D(:,:,i), ...
                    s1col(:,i), s1row(:,i), s12(:,i));
                if ~ok
                    return
                end
            end
            
            %--------------------------------------------------------------------------
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
        error('HERBERT:boxArrayClass:invalid_argument', ...
            'Invalid shape of array of shifts')
    end
end

end
