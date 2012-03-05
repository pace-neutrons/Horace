function wout = rebin2(win, varargin)
% Rebin a tofspectrum object or array of tofspectrum objects along the x-axis
%
%   >> wout = rebin2 (win, descr)
%   >> wout = rebin2 (win, descr, 'int')
%   
% Input:
% ------
%   win     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries 
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Single bin
%           - [x1,x2,...xn]         Set of bin boundaries
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   average of the function defined by linear interpolation between the data points
%
% Output:
% -------
%   wout    Output object or array of objects
%
% EXAMPLES
%   >> wout = rebin2 (win, [])
%   >> wout = rebin2 (win, 10)
%   >> wout = rebin2 (win, [2000,3000])
%   >> wout = rebin2 (win, [2000,Inf])
%   >> wout = rebin2 (win, [2000,3000,4000,5000,6000])
%
% See also corresponding function rebin which accepts a rebin descriptor
% of form [x1,dx1,x2,dx2,...xn] instead of a set of bin boundaries

wout=win;

% Return if trivial case
if numel(varargin)==0
    return
end

% Determine if have a valid descriptor from a class
if numel(varargin)>=1 && ~isnumeric(varargin{1}) && ~ischar(varargin{1})    % exclude case of numeric or point integration option
    if isa(varargin{1},'tofspectrum') && isscalar(varargin{1})
        xbounds=getx(varargin{1}.IX_dataset_2d,1);
    else
        try
            xbounds=getx(varargin{1},1);
        catch
            error('Check type and size of the object providing the rebin parameters')
        end
    end
    for i=1:numel(wout)
        if numel(varargin)==1
            wout(i).IX_dataset_2d=rebin2_x(win(i).IX_dataset_2d,xbounds);     % rebin with defined array of bin boundaries
        else
            wout(i).IX_dataset_2d=rebin2_x(win(i).IX_dataset_2d,xbounds,varargin{2:end});     % rebin with defined array of bin boundaries
        end
    end
else
    for i=1:numel(wout)
        wout(i).IX_dataset_2d=rebin2_x(win(i).IX_dataset_2d,varargin{:});
    end
end
