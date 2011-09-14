function [ok, mess, dout] = checkfields (d)
% Check fields for spe objects
%
%   >> [ok, mess] = checkfields (d)
%
%   d       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valiw.
%   dout    Output structure or object of the class 
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
%   >> [ok, message,dout,...] = checkfields (d,...)

% Original author: T.G.Perring
    
% Initialise
% ------------
% Fields:
fields = {'filename';'filepath';'S';'ERR';'en'};  % column

ok=true;
mess = '';
dout = d;

if ~isequal(fieldnames(dout),fields)
    ok=false; mess='fields inconsistent with spe object'; return
end

% Check contents of fields. Not exhaustive, but should eliminate common errors
% ------------------------------------------------------------------------------
if ~is_ok_row_string(dout.filename)
    ok=false; mess='Check filename string'; return
end
if ~is_ok_row_string(dout.filepath)
    ok=false; mess='Check filepath string'; return
end

ne=size(dout.S,1);
if ~isnumeric(dout.S)||~isnumeric(dout.ERR)||~isnumeric(dout.en)
    ok=false; mess='Signal,error and energy bin boundary arrays must be numeric'; return
end
if length(size(dout.S))~=2
    ok=false; mess='Signal array must be ne x ndet array (ne=no. energy bins, ndet=no. detectors)'; return
end
if ~isequal(size(dout.S),size(dout.ERR))
    ok=false; mess='Signal and error arrays do not match in size'; return
end
if ~isvector(dout.en)||numel(dout.en)~=ne+1
    ok=false; mess='Check number of energy bin boundaries'; return
end

% ensure energy boundaries form a column vector
dout.en=dout.en(:);


%==================================================================================================
function ok = is_ok_row_string(arg)
% Check if argument is a row character string, or an empty string
if (ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1))
    ok=true;
else
    ok=false;
end
