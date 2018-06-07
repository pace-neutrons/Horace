function   [save_out,name,argi] = check_save_provided_(name,varargin)
% Verify input to check if option '-save' has been provided
%
argi = varargin;
if strcmpi(name,'-save')
    save_out=true;
    if numel(argi )>0 % if the save is provided, the second argument would probably be a test name
        name = 'TestCaseWithSave';
    else
        name = mfilename('class');
    end
else
    save_out=false;
end
