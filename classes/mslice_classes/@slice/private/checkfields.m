function [ok, mess, dout] = checkfields (d)
% Check fields for mslice/Tobyfit cut objects
%
%   >> [ok, mess, dout] = checkfields (d)
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
fields = {'xbounds';'ybounds';'x';'y';'c';'e';'npixels';'pixels';...
          'x_label';'y_label';'z_label';'title';...
          'x_unitlength';'y_unitlength';'SliceFile';'SliceDir'};  % column
      
ok=true;
mess = '';
dout = d;

if ~isequal(fieldnames(dout),fields)
    ok=false; mess='fields inconsistent with mslice/Tobyfit slice object'; return
end

% Check contents of fields. Not exhaustive, but should eliminate common errors
% ------------------------------------------------------------------------------
nx=numel(dout.xbounds)-1;
ny=numel(dout.ybounds)-1;
npnt=numel(dout.npixels);
if npnt==0
    ok=false; mess='Number of points in slice is zero'; return
end
if ~isvector(dout.xbounds)||~isnumeric(dout.xbounds)||~all(isfinite(dout.xbounds))||nx<1
    ok=false; mess='Check number and type of xboundary values'; return
end
if ~isvector(dout.ybounds)||~isnumeric(dout.ybounds)||~all(isfinite(dout.ybounds))||ny<1
    ok=false; mess='Check number and type of yboundary values'; return
end
if ~isvector(dout.x)||~isnumeric(dout.x)||~all(isfinite(dout.x))||numel(dout.x)~=nx*ny
    ok=false; mess='Check number and type of x values'; return
end
if ~isvector(dout.y)||~isnumeric(dout.y)||~all(isfinite(dout.y))||numel(dout.y)~=nx*ny
    ok=false; mess='Check number and type of y values'; return
end
if ~isvector(dout.c)||~isnumeric(dout.c)||numel(dout.c)~=npnt
    ok=false; mess='Check number and type of signal values'; return
end
if ~isvector(dout.e)||~isnumeric(dout.e)||numel(dout.e)~=npnt
    ok=false; mess='Check number and type of error values'; return
end
if ~isvector(dout.npixels)||~isnumeric(dout.npixels)||any(~isfinite(dout.npixels))||any(dout.npixels<0)||npnt~=nx*ny
    ok=false; mess='Check size and type of number-of-pixels array'; return
end
if ~isnumeric(dout.pixels)||~all(isfinite(dout.pixels(:)))||size(dout.pixels,1)~=sum(dout.npixels)||size(dout.pixels,2)~=7
    ok=false; mess='Check number and type of pixel information array: [npixtot x 7]'; return
end

% ensure arrays are rows (apart from dout.pixels, whose shape has already been checked)
dout.xbounds=dout.xbounds(:)';
dout.ybounds=dout.ybounds(:)';
dout.x=dout.x(:)';
dout.y=dout.y(:)';
dout.c=dout.c(:)';
dout.e=dout.e(:)';
dout.npixels=dout.npixels(:)';


if ~is_ok_label(dout.x_label)
    ok=false; mess='Check x_label'; return
end
if ~is_ok_label(dout.y_label)
    ok=false; mess='Check y_label'; return
end
if ~is_ok_label(dout.z_label)
    ok=false; mess='Check z_label'; return
end
if ~is_ok_label(dout.title)
    ok=false; mess='Check title'; return
end
[ok,val,converted] = is_ok_numeric_scalar(dout.x_unitlength);
if ok && val>=0
    if converted, dout.x_unitlength=val; end
else
    mess='Check x_unitlength'; return
end
[ok,val,converted] = is_ok_numeric_scalar(dout.y_unitlength);
if ok && val>=0
    if converted, dout.y_unitlength=val; end
else
    mess='Check y_unitlength'; return
end
if ~is_ok_row_string(dout.SliceFile)
    ok=false; mess='Check SliceFile string'; return
end
if ~is_ok_row_string(dout.SliceDir)
    ok=false; mess='Check SliceDir string'; return
end

    
%==================================================================================================
function ok = is_ok_label(arg)
% Check if argument is a row character string, or an empty string, or cell array of strings
if (ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1)) || iscellstr(arg)
    ok=true;
else
    ok=false;
end

%==================================================================================================
function ok = is_ok_row_string(arg)
% Check if argument is a row character string, or an empty string
if (ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1))
    ok=true;
else
    ok=false;
end

%==================================================================================================
function [ok,val,converted] = is_ok_numeric_scalar(arg)
% Check if argument is a numeric scalar, or is a string that contains a single numeric scalar

ok=true;            % starting assumption
converted=false;    % starting assumption

if isscalar(arg) && isnumeric(arg)
    val=arg;
else
    if iscellstr(arg), arg=char(arg); end
    if ischar(arg) && ~isempty(arg) && size(arg,1)==1
        val=str2num(arg);
        if numel(val)==1
            converted=true;
        else
            ok=false;
            val=[];
        end
    else
        ok=false;
        val=[];
    end
end
