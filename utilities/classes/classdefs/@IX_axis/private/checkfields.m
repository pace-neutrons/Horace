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
%     isvalid.m and the consequent call to checkfields.m ...
%       
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
    
% Original author: T.G.Perring


fields = {'caption';'units';'code';'ticks'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    % Check caption
    if ischar(w.caption) && numel(size(w.caption))==2
        if isempty(w.caption)
            wout.caption={};
        else
            wout.caption=cellstr(w.caption);
        end
    elseif ~iscellstr(w.caption)
        message='Caption must be character or cell array of strings'; return
    end
    
    % Check units
    if isstring(w.units)
        if isempty(w.units)
            wout.units='';
        end
    else
        message='Axis units must be character string'; return
    end
    
    % Check code
    if isstring(w.code)
        if isempty(w.code)
            wout.code='';
        end
    else
        message='Units code must be character string'; return
    end
    
    % Check ticks
    if isstruct(w.ticks)
        if numel(fieldnames(w.ticks))==2 && all(isfield(w.ticks,{'positions','labels'}))
            if isempty(w.ticks.positions)
                wout.ticks.positions=[];
            elseif isnumeric(w.ticks.positions)
                if ~isrowvector(w.ticks.positions), wout.ticks.positions=w.ticks.positions(:)'; end
            else
                message='tick positions must be a numeric vector'; return
            end
            
            if isempty(w.ticks.labels)
                wout.ticks.labels={};
            elseif iscellstr(w.ticks.labels)
                if ~isrowvector(w.ticks.labels), wout.ticks.labels=w.ticks.labels(:)'; end
            elseif ischar(w.ticks.labels) && numel(size(w.ticks.labels))==2
                wout.ticks.labels=cellstr(w.ticks.labels)';
            else
                message='tick labels must be a cellstr or character array'; return
            end
            
            if ~isempty(wout.ticks.labels) && numel(wout.ticks.labels)~=numel(wout.ticks.positions);
                message='If tick labels are provided, the number of labels must match the number of tick positions'; return
            end

            wout.ticks=orderfields(wout.ticks,{'positions','labels'});
        else
            message='ticks information must be a structure with fields ''positions'' and ''labels'''; return
        end
    else
        message='ticks information must be a structure with fields ''positions'' and ''labels'''; return
    end
    
else
    message='Fields inconsistent with class type'; return
end

% OK if got to here
ok=true;
