function [return_horace_format,file_name_changed,new_file_name,lext]=parse_par_file_arg(this,fext,varargin)
% method parses input arguments of the script, checks if the file defined
% by the class or possibly redefined by the arguments exist and what file
% format should be used when processing this file.
%
% Returns:
% if the
return_horace_format = false;
the_file_name        = this.par_file_name;
new_file_name        = the_file_name;
file_name_changed    = false;
% verify if the parameters request other file name and horace data format;
if nargin>2
    [new_file_name,file_format]=parse_par_arg(the_file_name,varargin{:});
    if ~isempty(file_format)
        return_horace_format = true;
    end
    if ~strcmp(new_file_name,the_file_name)
        [ok,mess,new_file_name]  = check_file_exist(new_file_name,fext);
        if ~ok
            error('A_LOADER:load_par',mess);
        else
            file_name_changed  = true;
            the_file_name = new_file_name;
        end
    end
end

[fp,fn,fext] = fileparts(the_file_name);
lext = lower(fext);




function [file_name,file_format]= parse_par_arg(old_file_name,varargin)
% function verifies if input parameters present in varargin redefine the filename correctly
%
% It is a private function used by load_par methods of all data loaders, which
% helps these methods to identify if the method should return result as the
% horace structure and if the input filename have been redefined in input
% parameters;
%
file_name=old_file_name;
file_format='';

if nargin == 1;    return;
end
%
if nargin>1
    if ~ischar(varargin{1})
        error('PARSE_PAR_ARG:invalid_argument','first argument has to be either file name or a symbol parameter -hor');
    end
    if strncmpi(varargin{1},'-hor',4)
        file_format='-hor';
        return;
    else
        file_name=varargin{1};
        if nargin==3
            if ~strncmpi(varargin{2},'-hor',4)
                if get(herbert_config,'log_level')>-1
                    warning('PARSE_PAR_ARG:invalid_argument',' third argument, if present, has to be the key -hor, assuming -hor');
                end
            end
            file_format='-hor';
        end
    end
end
