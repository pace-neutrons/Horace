function  this = set_file_name_(this,new_name)
% private function which sets input file name for a loader verifying first 
% if the file with appropriate name exist
%
if isempty(new_name)
    % disconnect detector information in memory from a par file
    this.file_name_ = '';
    if isempty(this.S_)
        this.en_ = [];
        this.n_detindata_=[];
    end
    f_name = '';
else
    [ok,mess,f_name] = check_file_exist(this,new_name);
    if ~ok
        error('HERBERT:a_loader:invalid_argument',mess);
    end
end
if strcmp(this.file_name_,f_name)
    return;
end
if ~isempty(this.file_name_)
    this= this.delete();
end
this=this.set_data_info(f_name);
