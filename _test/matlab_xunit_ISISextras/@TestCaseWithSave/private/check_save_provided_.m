function   [save_out,name,argi] = check_save_provided_(name,varargin)
% Verify input to check if option '-save' has been provided
%
argi = varargin;
if strcmpi(name,'-save')
    save_out=true;
    if numel(argi )>0 % if the save is provided, the second argument would probably be a test file name
        if numel(argi ) > 1
            name = varargin{2};
            argi = varargin(1);
        else
            name = 'TestCaseWithSave';
        end
    else
        name = mfilename('class');
    end
else
    save_out=false;
    if numel(argi) > 0
        if numel(argi ) > 1
            name = varargin{2};
            argi = varargin(1);
        else
            name = 'TestCaseWithSave';
        end        
    else
        name = mfilename('class');        
    end
end
