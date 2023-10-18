function wout = coordinates_calc(obj,name)
% Replace the sqw's signal and variance data with coordinate values (see below)
%
%   >> wout=coordinates_calc(w, name)
%
% Input:
% -----
%   w       Input sqw object or array of sqw objects
%   name    Name of the parameter to use as the intensity
%          Valid parameter names are:
%               'd1','d2',...       Display axes (for as many dimensions as
%                                  the sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|
%
% Output:
% -------
%   w    Output sqw object with the signal and variance of the pixels set to the
%          value of the input parameter name
%          (also updates attached DnD data object to reflect this)
%
% EXAMPLE
%   >> wout=coordinates_calc(w,'h')   % set the intensity to the Q-component along a*
%
% Formerly known as `signal`
%
% Original author: T.G.Perring
%

if nargin~=2
    error('HORACE:coordinates_calc:invalid_argument', ...
        'this function requires two input arguments')
elseif isempty(name) || ~is_string(name)
    error('HORACE:coordinates_calc:invalid_argument', ...
        'Second argument of this function should be char string selected from input list. Its type is %s',...
        class(name));
end
wout = copy(obj);
page_op = PageOp_coord_calc;

ind = find(ismember(page_op.xname,name));
if isempty(ind)
    error('HORACE:sqw:invalid_argument', ...
        'Input parameter must be one or group of parameters from list %s\n. It is: %s',...
        disp2str(page_op.xname),disp2str(name))
end

for i=1:numel(wout)

    % Check consistency of coordinate name(s) with dimensions of sqw object
    if ind <= 4 && ind > dimensions(wout(i)) % Each set of 4 (d1, d2, d3, d4) + 4 (h, k, l, e) + Q
        error('HORACE:sqw:invalid_argument', ...
            'Coordinate name %s for object N%d request axes numbers higher then the dimensionality of sqw object (=%d)',...
            page_op.xname{ind},i, dimensions(wout(i)));
    end
    page_op = page_op.init(wout(i),ind);
    wout(i) = wout(i).apply_c(page_op);
end

end
