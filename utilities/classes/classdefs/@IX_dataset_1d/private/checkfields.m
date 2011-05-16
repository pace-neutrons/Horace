function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valiw.
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
    if ischar(w.title)||iscellstr(w.title)
        if ischar(w.title)
            wout.title=cellstr(w.title);
        end
    else
        message='Title must be character array or cell array of strings'; return
    end
    sum_empty=isempty(w.signal)+isempty(w.error)+isempty(w.x);
    if sum_empty==0         % none are empty
        if ~isa(w.signal,'double')||~isvector(w.signal)||~isa(w.error,'double')||~isvector(w.error)||~isa(w.x,'double')||~isvector(w.x)
            message='x-axis values, signal and error arrays must all be double precision vectors'; return
        end
        if numel(w.signal)~=numel(w.error)
            message='Length of signal and error arrays must be the same'; return
        end
        if ~(numel(w.x)==numel(w.signal)||numel(w.x)==numel(w.signal)+1)
            message='Check lengths of x-axis and signal arrays'; return
        end
    elseif sum_empty==3     % all empty
        wout.signal=[];
        wout.error=[];
        wout.x=[];
    else
        message='Check contents of signal, error and x arrays';
    end
    if ischar(w.s_axis)||iscellstr(w.s_axis)
        wout.s_axis=IX_axis(w.s_axis);
    elseif ~isa(w.s_axis,'IX_axis')
        message='signal axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if ischar(w.x_axis)||iscellstr(w.x_axis)
        wout.x_axis=IX_axis(w.x_axis);
    elseif ~isa(w.x_axis,'IX_axis')
        message='x-axis annotation must be character array or IX_axis object (type help IX_axis)'; return
    end
    if (islogical(w.x_distribution)||isnumeric(w.x_distribution))&&isscalar(w.x_distribution)
        if isnumeric(w.x_distribution)
            wout.x_distribution=logical(w.x_distribution);
        end
    else
        message='Distribution type must be true or false'; return
    end
    if size(w.signal,2)==1, wout.signal=w.signal'; end  % make row vector
    if size(w.error,2)==1, wout.error=w.error'; end
    if size(w.x,2)==1, wout.x=w.x'; end
else
    message='Fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
