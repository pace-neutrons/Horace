function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid object, empty string if is valid.
%   wout    Output structure or object of the class 
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to 
%     isvaliw.m and the consequent call to checkfields.m ...
%       
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
%
% Ensures the following is returned
%
% 	title				cellstr         Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (column vector, size(signal)==[n1,1) where n1=no. points along x axis)
% 	error				        		Standard error (column vector, size matches that of signal)
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                                     (Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x					double      	Values of bin boundaries (if histogram data) (row vector)
% 						                Values of data point positions (if point data) (row vector)
% 	x_axis				IX_axis			x-axis object containing caption and units codes
%                                     (Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
% 	x_distribution      logical         Distribution data flag (true is a distribution; false otherwise)

% Original author: T.G.Perring

% We will allow the following changes:
%   - x, signal, error arrays can be columns; will be converted to rows
%   - s_axis, x_axis an be character arrays or cell arrays, in which case replaced by IX_axis(s_axis), IX_axis(x_axis)
%   - x_distribution can be numeric 0 or 1

fields = {'title';'signal';'error';'s_axis';'x';'x_axis';'x_distribution'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ischar(wout.title)||iscellstr(wout.title)
        if ischar(wout.title)
            wout.title=cellstr(wout.title);
        else
            wout.title=wout.title(:);
        end
    else
        message='Title must be character array or cell array of strings'; return
    end
    if numel(size(wout.x))==2 && all(size(wout.x)==[0,0]), wout.x=zeros(1,0); end        % input was e.g. '' or [], so assume to mean default
    if numel(size(wout.signal))==2 && all(size(wout.signal)==[0,0]), wout.signal=zeros(0,1); end     % input was e.g. '' or [], so assume to mean default
    if numel(size(wout.error))==2 && all(size(wout.error)==[0,0]), wout.error=zeros(0,1); end        % input was e.g. '' or [], so assume to mean default
    if ~isa(wout.signal,'double')||~isvector(wout.signal)||~isa(wout.error,'double')||~isvector(wout.error)||~isa(wout.x,'double')||~isvector(wout.x)
        message='x-axis values, signal and error arrays must all be double precision vectors'; return
    end
    if numel(wout.signal)~=numel(wout.error)
        message='Length of signal and error arrays must be the same'; return
    end
    if ~(numel(wout.x)==numel(wout.signal)||numel(wout.x)==numel(wout.signal)+1)
        message='Check lengths of x-axis and signal arrays'; return
    end
    if ~all(isfinite(wout.x))
        message='Check x-axis values are all finite (i.e. no Inf or NaN)'; return
    else
        if numel(wout.x)==numel(wout.signal) && any(diff(wout.x)<0)
            message='Check x-axis values are monotonic increasing'; return
        elseif numel(wout.x)==numel(wout.signal)+1 && ~all(diff(wout.x)>0)
            message='Histogram bin boundaries along x-axis must be strictly monotonic increasing'; return
        end
    end
    if ischar(wout.s_axis)||iscellstr(wout.s_axis)
        wout.s_axis=IX_axis(wout.s_axis);
    elseif ~isa(wout.s_axis,'IX_axis')
        message='signal axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if ischar(wout.x_axis)||iscellstr(wout.x_axis)
        wout.x_axis=IX_axis(wout.x_axis);
    elseif ~isa(wout.x_axis,'IX_axis')
        message='x-axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if (islogical(wout.x_distribution)||isnumeric(wout.x_distribution))&&isscalar(wout.x_distribution)
        if isnumeric(wout.x_distribution)
            wout.x_distribution=logical(wout.x_distribution);
        end
    else
        message='Distribution type must be true or false'; return
    end
    if size(wout.signal,1)==1, wout.signal=wout.signal'; end  % make column vector
    if size(wout.error,1)==1, wout.error=wout.error'; end
    if size(wout.x,2)==1, wout.x=wout.x'; end     % make row vector
else
    message='Fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
