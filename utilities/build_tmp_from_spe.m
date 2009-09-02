function list=build_tmp_from_spe(varargin)
% function builds the list of the tmp files which corresponds to the input
% spe files
% the first argument: the list of spe files or the folder where these files
% reside
% the second argument (optional)
% the folder to place output tmp files; if not present, files will be
% placed in spe files folder
% $Revision$ ($Date$)
if(nargin==1)
    if(iscell(varargin{1}))
        filename=varargin{1}{1};
        [pathstr, name, ext, versn] = fileparts(filename);
        spe_list=varargin{1};
    elseif(isdir(varargin{1}))
        spe_list=file_list(varargin{1},'spe');
    else
        error(['usage: build_tmp_from_spe({spe_file list, folder with spe files},[output directory])\n'...
               '****** where the first argument is the list of spe files or folder where these files reside and \n'...
               '****** the optional second argument is the folder where tmp files should be placed. If not present,\n'...
               '****** the final files will be placed into the spe files folder'
            ]);
    end
    list=build_tmp_list_in_theFolderGiven(spe_list,pathstr);
elseif(nargin == 2)
    list=build_tmp_list_in_theFolderGiven(varargin{1},varargin{2});
else
    error(' usage: buld_tmp_from_spe(list of spe files, [folder to place tmp_files])');
end
end
