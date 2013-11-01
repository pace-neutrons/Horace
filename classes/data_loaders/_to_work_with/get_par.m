function [par,this] =get_par(this,file_name)
% usage: 
%>> par =get_par(run_data,[new_file_name])
%
%
% $Revision$ ($Date$)
%
if exist('file_name','var')||isempty(this.par)
    this = load_par(this,file_name);    
    this.nDetectors=size(this.par,2);
end

par = this.par;


