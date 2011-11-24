function [par,this] =get_par(this,file_name)
% usage: 
%>> par =get_par(run_data,[new_file_name])
%
%
% $Revision: 508 $ ($Date: 2010-11-29 15:50:24 +0000 (Mon, 29 Nov 2010) $)
%
if exist('file_name','var')||isempty(this.par)
    this = load_par(this,file_name);    
    this.nDetectors=size(this.par,2);
end

par = this.par;


