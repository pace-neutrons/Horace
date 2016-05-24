function  this = set_file_name_(this,new_name)
% privare function which sets input file name for a loader verifying if the
% file exist first
%
if isempty(new_name)
    % disconnect detector information in memory from a par file
    this.file_name_ = '';
    if isempty(this.S_)
        this.en_ = [];
        this.n_detindata_=[];
    end
else
    [ok,mess,f_name] = check_file_exist(this,new_name);
    if ~ok
        error('A_LOADER:set_file_name',mess);
    end
end
if ~strcmp(this.data_file_name_,f_name)
    this= this.delete();
    this=this.set_data_info(f_name);
else
    return
end
