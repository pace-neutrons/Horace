function   [save_out,name,argi] = check_save_provided_(name,varargin)
% Verify input to check if option '-save' has been provided
%
argi = varargin;
if strcmpi(name,'-save')
    save_out=true;
    if numel(argi )>0
        name = argi {1};
        argi = argi(2:end);
    else
        name = mfilename('class');
    end
else
    save_out=false;
end
