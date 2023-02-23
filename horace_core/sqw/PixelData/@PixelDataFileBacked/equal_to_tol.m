function [ok, mess] = equal_to_tol(obj, other_pix, varargin)
%% EQUAL_TO_TOL Check if two PixelData objects are equal to a given tolerance
%
% Input:
% ------
% pix        The first pixel data object to compare.
%
% other_pix  The second pixel data object to compare.
%
% tol        Tolerance criterion for numeric arrays
%            (default = [0, 0] i.e. equality)
%            It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%            If either criterion is satisfied then equality within tolerance
%            is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%            A scalar tolerance can be given where the sign determines if
%            the tolerance is absolute or relative:
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%            Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%
% Keyword Input:
% ---------------
% nan_equal  Treat NaNs as equal (true or false; default=true).
%
% name_a     Explicit name of variable a for use in messages
%            Usually not required, as the name of a variable will
%            be discovered. However, if the input argument is an array
%            element e.g. my_variable{3}  then the name is not
%            discoverable in Matlab, and default 'input_1' will be
%            used unless a different value is given with the keyword 'name_a'.
%            (default = 'input_1').
%
% name_b     Explicit name of variable b for use in messages.
%            The same comments apply as for 'name_a' except the default is
%            'input_2'.
%            (default = 'input_2').
%
parse_args(varargin{:});

[ok, mess] = validate_other_pix(obj, other_pix);
if ~ok
    return
end

if other_pix.is_filebacked

    for i = 1:obj.num_pages
        obj.page_num = i;
        other_pix.page_num = i;

        [ok, mess] = equal_to_tol(obj.data, other_pix.data, varargin{:});
        if ~ok
            break;
        end
    end

else
    for i = 1:obj.num_pages
        obj.page_num = i;

        [start_idx, end_idx] = obj.get_page_idx_();
        [ok, mess] = equal_to_tol(obj.data, other_pix.data(:, start_idx:end_idx), varargin{:});
        if ~ok
            break;
        end

    end
end

end

function [ok, mess] = validate_other_pix(obj, other_pix)

ok = true;
mess = '';

if ~isa(other_pix, 'PixelDataBase')
    ok = false;
    mess = sprintf('Objects of class ''%s'' and ''%s'' cannot be equal.', ...
        class(obj), class(other_pix));
    return
end

if obj.num_pixels ~= other_pix.num_pixels
    ok = false;
    mess = sprintf(['PixelData objects are not equal. ' ...
        'Argument 1 has %i pixels, argument 2 has %i'], ...
        obj.num_pixels, other_pix.num_pixels);
    return
end

if other_pix.is_filebacked && obj.page_size ~= other_pix.page_size
    ok = false;
    mess = sprintf(['PixelData objects have different page ' ...
        'sizes.\nFound page sizes %i and %i.'], obj.page_size, ...
        other_pix.page_size);
    return
end

end


function parse_args(varargin)
parser = inputParser();
% these params are used for validation only, they will be passed to
% Herbert's equal_to_tol via varargin
parser.addOptional('tol', [0, 0], @(x) (numel(x) <= 2));
parser.addParameter('nan_equal', true, @islognumscalar);
parser.addParameter('name_a', 'input_1', @ischar);
parser.addParameter('name_b', 'input_2', @ischar);
parser.KeepUnmatched = true;  % ignore unmatched parameters
parser.parse(varargin{:});
end
