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
% Fields (if single crystal data, and mfit .cut format, then there will be extra fields):
fields = {'x';'y';'e';'npixels';'pixels';'x_label';'y_label';'title';'CutFile';'CutDir';'appendix'};  % column
sx_mfit_fields = {'MspFile';'MspDir';'efixed';'emode';'sample';'as';'bs';'cs';'aa';'bb';'cc';'ux';'uy';'uz';'vx';'vy';'vz';'psi_samp'};

ok = true;
mess = '';
dout = d;

if isequal(fieldnames(dout),fields)             % mfit .cut format
    % Check appendix
    if ~isempty(dout.appendix)
        if isequal(fieldnames(dout.appendix),sx_mfit_fields)
            cut_type='sx_mfit';
        else
            ok=false; mess='fields of appendix information inconsistent with mslice/Tobyfit cut object'; return
        end
    else
        dout.appendix=struct([]);   % make standard empty structure
    end
elseif isequal(fieldnames(d),fields(1:end-1))   % ordinary .cut format
    dout.appendix=struct([]);   % make standard empty structure
else
    ok=false; mess='fields inconsistent with mslice/Tobyfit cut object'; return
end

% Check contents of fields. Not exhaustive, but should eliminate common errors
% ------------------------------------------------------------------------------
npnt=numel(dout.npixels);
if npnt==0
    ok=false; mess='Number of points in cut is zero'; return
end
if ~isvector(dout.x)||~isnumeric(dout.x)||~all(isfinite(dout.x))||numel(dout.x)~=npnt
    ok=false; mess='Check number and type of x values'; return
end
if ~isvector(dout.y)||~isnumeric(dout.y)||numel(dout.y)~=npnt
    ok=false; mess='Check number and type of y values'; return
end
if ~isvector(dout.e)||~isnumeric(dout.e)||numel(dout.e)~=npnt
    ok=false; mess='Check number and type of error values'; return
end
if ~isvector(dout.npixels)||~isnumeric(dout.npixels)||any(~isfinite(dout.npixels))||any(dout.npixels<1)
    ok=false; mess='Check size and type of number-of-pixels array'; return
end
if ~isnumeric(dout.pixels)||~all(isfinite(dout.pixels(:)))||size(dout.pixels,1)~=sum(dout.npixels)||size(dout.pixels,2)~=6
    ok=false; mess='Check number and type of pixel information array: [npixtot x 6]'; return
end

if ~is_ok_label(dout.x_label)
    ok=false; mess='Check x_label'; return
end
if ~is_ok_label(dout.y_label)
    ok=false; mess='Check y_label'; return
end
if ~is_ok_label(dout.title)
    ok=false; mess='Check title'; return
end

if ~is_ok_row_string(dout.CutFile)
    ok=false; mess='Check CutFile string'; return
end
if ~is_ok_row_string(dout.CutDir)
    ok=false; mess='Check CutDir string'; return
end

% ensure arrays are rows (apart from dout.pixels, whose shape has already been checked)
dout.x=dout.x(:)';
dout.y=dout.y(:)';
dout.e=dout.e(:)';
dout.npixels=dout.npixels(:)';


% Now check contents of appendix, and convert to relevant type if required
% --------------------------------------------------------------------------
if ~isempty(dout.appendix)
    if strcmp(cut_type,'sx_mfit')
        if ~is_ok_row_string(dout.appendix.MspFile)
            ok=false; mess='Appendix field ''MspFile'' has incorrect type'; return
        end
        
        if ~is_ok_row_string(dout.appendix.MspDir)
            ok=false; mess='Appendix field ''MspDir'' has incorrect type'; return
        end
                
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.efixed);
        if ok && val>0
            if converted, dout.appendix.efixed=val; end
        else
            mess='Check appendix field ''efixed'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.emode);
        if ok && (val==1 || val==2)
            if converted, dout.appendix.emode=val; end
        else
            mess='Check appendix field ''emode'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.sample);
        if ok && val==1
            if converted, dout.appendix.sample=val; end
        else
            mess='Check appendix field ''sample'''; return
        end

        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.as);
        if ok && val>0
            if converted, dout.appendix.as=val; end
        else
            mess='Check appendix field ''as'''; return
        end

        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.bs);
        if ok && val>0
            if converted, dout.appendix.bs=val; end
        else
            mess='Check appendix field ''bs'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.cs);
        if ok && val>0
            if converted, dout.appendix.cs=val; end
        else
            mess='Check appendix field ''cs'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.aa);
        if ok && val>0
            if converted, dout.appendix.aa=val; end
        else
            mess='Check appendix field ''aa'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.bb);
        if ok && val>0
            if converted, dout.appendix.bb=val; end
        else
            mess='Check appendix field ''bb'''; return
        end
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.cc);
        if ok && val>0
            if converted, dout.appendix.cc=val; end
        else
            mess='Check appendix field ''cc'''; return
        end
        
        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.ux);
        if ok
            if converted, dout.appendix.ux=val; end
        else
            mess='Check appendix field ''ux'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.uy);
        if ok
            if converted, dout.appendix.uy=val; end
        else
            mess='Check appendix field ''uy'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.uz);
        if ok
            if converted, dout.appendix.uz=val; end
        else
            mess='Check appendix field ''uz'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.vx);
        if ok
            if converted, dout.appendix.vx=val; end
        else
            mess='Check appendix field ''vx'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.vy);
        if ok
            if converted, dout.appendix.vy=val; end
        else
            mess='Check appendix field ''vy'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.vz);
        if ok
            if converted, dout.appendix.vz=val; end
        else
            mess='Check appendix field ''vz'''; return
        end

        
        [ok,val,converted] = is_ok_numeric_scalar(dout.appendix.psi_samp);
        if ok
            if converted, dout.appendix.psi_samp=val; end
        else
            mess='Check appendix field ''psi_samp'''; return
        end

    end
    
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
