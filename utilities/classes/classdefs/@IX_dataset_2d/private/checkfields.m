function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valiwout.
%   wout    Output structure or object of the class 
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to 
%     isvaliwout.m and the consequent call to checkfields.m ...
%       
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
%
% Ensures the following is returned
%
% 	title				cellstr         Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (row vector)
% 	error				        		Standard error (row vector)
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                                     (Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x					double      	Values of bin boundaries (if histogram data) (row vector)
% 						                Values of data point positions (if point data) (row vector)
% 	x_axis				IX_axis			x-axis object containing caption and units codes
%                                     (Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)
%
%   y                   double          -|
%   y_axis              IX_axis          |- same as above but for y-axis
%   y_distribution      logical         -|

% Original author: T.G.Perring

% We will allow the following changes:
%   - x, y, signal, error arrays can be columns; will be converted to rows
%   - s_axis, x_axis, y_axis can be character arrays or cell arrays, in which case replaced by IX_axis(s_axis), IX_axis(x_axis)
%   - x_distribution, y_distribution can be numeric 0 or 1

fields = {'title';'signal';'error';'s_axis';'x';'x_axis';'x_distribution';'y';'y_axis';'y_distribution'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ischar(wout.title)||iscellstr(wout.title)
        if ischar(wout.title)
            wout.title=cellstr(wout.title);
        end
    else
        message='Title must be character array or cell array of strings'; return
    end
    if numel(size(wout.x))==2 && all(size(wout.x)==[0,0]), wout.x=zeros(1,0); end        % input was e.g. '' or [], so assume to mean default
    if numel(size(wout.y))==2 && all(size(wout.y)==[0,0]), wout.y=zeros(1,0); end        % input was e.g. '' or [], so assume to mean default
    if numel(size(wout.signal))==2 && all(size(wout.signal)==[0,0]), wout.signal=zeros(0,0); end     % input was e.g. '' or [], so assume to mean default
    if numel(size(wout.error))==2 && all(size(wout.error)==[0,0]), wout.error=zeros(0,0); end        % input was e.g. '' or [], so assume to mean default
    if ~isa(wout.signal,'double')||numel(size(wout.signal))~=2||~isa(wout.error,'double')||numel(size(wout.error))~=2
        message='Signal and error arrays must be two-dimensional double precision arrays'; return
    end
    if ~isa(wout.x,'double')||~isvector(wout.x)||~isa(wout.y,'double')||~isvector(wout.y)
        message='x-axis values and y-axis values must be double precision vectors'; return
    end
    if numel(wout.signal)~=numel(wout.error)
        message='Number of elements in signal and error arrays must be the same'; return
    end
    if ~(numel(wout.x)==size(wout.signal,1)||numel(wout.x)==size(wout.signal,1)+1)
        message='Check lengths of x-axis and first dimension of signal array are compatible'; return
    end
    if ~(numel(wout.y)==size(wout.signal,2)||numel(wout.y)==size(wout.signal,2)+1)
        message='Check lengths of y-axis and second dimension of signal array are compatible'; return
    end
    if ~all(isfinite(wout.x))
        message='Check x-axis values are all finite (i.e. no Inf or NaN)'; return
    end
    if ~all(isfinite(wout.y))
        message='Check y-axis values are all finite (i.e. no Inf or NaN)'; return
    end
    dx=diff(wout.x);
    if any(dx<0)
        message='Check x-axis values are monotonic increasing'; return
    end
    dy=diff(wout.y);
    if any(dy<0)
        message='Check y-axis values are monotonic increasing'; return
    end
    if ischar(wout.s_axis)||iscellstr(wout.s_axis)
        wout.s_axis=IX_axis(wout.s_axis);
    elseif ~isa(wout.s_axis,'IX_axis')
        message='Signal axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if ischar(wout.x_axis)||iscellstr(wout.x_axis)
        wout.x_axis=IX_axis(wout.x_axis);
    elseif ~isa(wout.x_axis,'IX_axis')
        message='x-axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if ischar(wout.y_axis)||iscellstr(wout.y_axis)
        wout.y_axis=IX_axis(wout.y_axis);
    elseif ~isa(wout.y_axis,'IX_axis')
        message='y-axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if (islogical(wout.x_distribution)||isnumeric(wout.x_distribution))&&isscalar(wout.x_distribution)
        if isnumeric(wout.x_distribution)
            wout.x_distribution=logical(wout.x_distribution);
        end
    else
        message='Distribution type along x-axis must be true or false'; return
    end
    if (islogical(wout.y_distribution)||isnumeric(wout.y_distribution))&&isscalar(wout.y_distribution)
        if isnumeric(wout.y_distribution)
            wout.y_distribution=logical(wout.y_distribution);
        end
    else
        message='Distribution type along y-axis must be true or false'; return
    end
    if size(wout.x,2)==1, wout.x=wout.x'; end
    if size(wout.y,2)==1, wout.y=wout.y'; end
else
    message='Fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
