function varargout = sh_ass
% Shows the assignment of the ISIS data source
%
%   >> sh_ass
%   >> source = sh_ass  % returns the data source

global mgenie_globalvars

source=mgenie_globalvars.source;
if isempty(source.inst) || isempty(source.run_char) || isempty(source.ext)  % print individual components if not of form IIInnnnn.eee
    if nargout==0
        disp('------------------------------------------------------------------')
        if isempty(source.disk) && isempty(source.dir)
            disp('  location :')
        elseif isempty(source.dir)
            disp(['  location : ',source.disk])
        elseif isempty(source.disk)
            disp(['  location : ',source.dir])
        else
            location=fullfile(source.disk,source.dir);
            disp(['  location : ',location])
        end
        disp(['instrument : ' source.inst])
        if isempty(source.run_char)
            disp('       run :')
        else
            disp(['       run : ' num2str(round(source.run))])
        end
        disp([' extension : ' source.ext])
    else
        varargout{1}='';
    end
else
    [filename,ok]=translate_read(source.filename);
    if ~ok
        mess=['Input data file does not exist: ',source.filename];
        if nargout==0
            error(mess)
        else
            varargout{1}=mess;
        end
    else
        if nargout==0
            disp(['Data source: ' source.filename])
        else
            varargout{1}=source.filename;
        end
    end
end
