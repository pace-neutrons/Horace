function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valid.
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
    
fields = {'name';'distance';'frequency';'radius';'curvature';'slit_width';...
          'slit_spacing';'width';'height';'energy';'phase';'ntable';'table'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ~isstring(w.name)
        message='Fermi chopper name must be a character string';
        return
    end
    for i=2:10
        if ~isnumeric(w.(fields{i})) || ~isscalar(w.(fields{i})) || w.(fields{i})<0
            message=['Parameter ''',fields{i},''' must be greater of equal to zero'];
            return
        end
    end
    if ~(isnumeric(w.phase)||islogical(w.phase)) || ~isscalar(w.phase)
        message='Parameter ''phase'' must be logical true or false';
        return
    end
    wout.phase=logical(w.phase);
    % Always recompute the lookup table
    if ~isnumeric(w.ntable) || ~isscalar(w.ntable) || floor(w.ntable)<2
        message='parameter ''ntable'' must be greater or equal to 2';
        return
    else
        wout.ntable=floor(w.ntable);
        wout.table=[];  % reset to empty - will fill properly later
    end
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here

% Update lookup table. Must account for wout being a structure (from constructor)
% and previously existing class that has one or more fields reset (from set)
if isa(wout,'IX_fermi_chopper')
    wout.table=set_sampling_table(wout);
else
    wout.table=set_sampling_table(class(wout,'IX_fermi_chopper'));
end
ok=true;
