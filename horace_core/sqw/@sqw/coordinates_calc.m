function w = coordinates_calc(w, name)
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

for i=1:numel(w)
    w(i) = coordinates_calc_(w(i), name);
end


end

function w = coordinates_calc_(w, name)
% Get the average values of one or more coordinates in each bin of an sqw object
%
%   >> xvals = coordinates_calc (w, name)
%
% Input:
% ------
%   w       sqw object
%   name   coordinate name (string)
%           Valid names are:
%               'd1','d2',...       Display axes (for as many dimensions as
%                                  the sqw object has)
%               'h', 'k', 'l'       r.l.u.
%               'E'                 energy transfer
%               'Q'                 |Q|
%
% Output:
% -------
%   xvals   numeric array of the bin-averaged coordinates.
%
%   xpix    numeric array of the pixel coordinates
%
%   xvar    Variance of coordinate in each bin (array size equal to that of
%          the signal array)
%
%   xdevsqr Cell array of corresponding squared-deviation for each pixel
%          (column vectors)
%
%
% Original author: T.G.Perring
%

% Get list of coordinates to average
% ------------------------------------
xname={'d1';'d2';'d3';'d4'; ...
    'h';'k';'l';'E'; ...
    'Q'};

ind = find(ismember(xname,name));
if isempty(ind)
    error('HORACE:sqw:invalid_argument', ...
        'Input parameter must be one or group of parameters from list %s\n. It is: %s',...
        disp2str(xname),disp2str(name))
end

% Check consistency of coordinate name(s) with dimensions of sqw object
if ind <= 4 && ind > dimensions(w) % Each set of 4 (d1, d2, d3, d4) + 4 (h, k, l, e) + Q
    error('HORACE:sqw:invalid_argument', ...
        'Some coordinate names %s request axes numbers higher then the dimensionality of sqw object (=%d)',...
        xname{ind}, dimensions(w));
end


% Evaluate required averages
% ---------------------------
% (Evaluate only those requested - keeps calculations down on what could be a long function call)

switch name
    case {'h','k','l'}

        this_proj = w.data.proj;
        hkl_proj = line_proj([1,0,0],[0,1,0],[0,0,1], ...
            'alatt',this_proj.alatt,'angdeg',this_proj.angdeg);
        get_ind = mod(ind-1, 4)+1;

        transform = @(pix) reg_transform(hkl_proj, get_ind, pix);

    case 'E'

        transform = @(pix) E_transform(w.data.proj, pix);

    case 'Q'

        this_proj = w.data.proj;
        hkl_proj = line_proj([1,0,0],[0,1,0],[0,0,1], ...
            'alatt',this_proj.alatt,'angdeg',this_proj.angdeg);
        get_ind = 1:3;

        transform = @(pix) Q_transform(hkl_proj, pix);

    case {'d1', 'd2', 'd3', 'd4'}

        pax=w.data.pax;
        dax=w.data.dax;

        get_ind = mod(ind-1, 4)+1;

        get_ind = pax(dax(get_ind));

        transform = @(pix) reg_transform(w.data.proj, get_ind, pix);

end

w = w.apply(transform, {}, true, true);

end

function pix = reg_transform(proj, ind, pix, npix)
uhkl = proj.transform_pix_to_img(pix);
pix.signal = uhkl(ind, :);
end

function pix = Q_transform(hkl_proj, pix, npix)

uhkl = hkl_proj.transform_pix_to_img(pix.q_coordinates);
uhkl = hkl_proj.transform_img_to_pix(uhkl);
pix.signal = vecnorm(uhkl, 2, 1);
end

function pix = E_transform(proj, pix, npix)
pix.signal = pix.dE + proj.offset(4);
end

