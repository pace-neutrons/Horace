function wout = rebin(win, varargin)
% Rebin a tofspectrum object or array of tofspectrum objects along the x-axis
%
%   >> wout = rebin (win, descr)
%   >> wout = rebin (win, descr, 'int')
%   
% Input:
% ------
%   win     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries 
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Change limits but bin boundaries in between unchanged
%           - [xlo,dx,xhi]          Lower and upper limits xlo and xhi, with intervening bins
%                                       dx>0    constant bins within the range
%                                       dx<0    logarithmic bins within the range
%                                              (if dx1<0, then must have x1>0, dx2<0 then x2>0 ...)
%                                       dx=0    retain existing bins within the range
%           - [x1,dx1,x2,dx2...xn]  Generalisation to multiple contiguous ranges
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
%   >> wout = rebin (win, [])
%   >> wout = rebin (win, 10)
%   >> wout = rebin (win, [2000,3000])
%   >> wout = rebin (win, [2000,Inf])
%   >> wout = rebin (win, [2000,10,3000])
%   >> wout = rebin (win, [5,-0.01,3000])
%   >> wout = rebin (win, [5,-0.01,1000,20,4000,50,20000])
%
% See also corresponding function rebin2 which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor

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
        wout(i).IX_dataset_2d=rebin_x(win(i).IX_dataset_2d,varargin{:});
    end
end
