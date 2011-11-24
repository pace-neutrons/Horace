function [par,this]=get_par(this,format)
% method returns detector par data from properly initiated data loader
%Usage: 
%>>par                    = get_par(rundata_instance,['-hor'])
%>>[par,rundata_instance] = get_par(rundata_instance,['-hor'])
%Where: 
% rundata_instance  -- properly initated instance of the rundata class
% '-hor', '-horace' -- optional parameter, requesting to return the
%                       detector information as horace structure, 
%                       rather then 6 column array with column:

%
if isempty(this.loader)
    error('RUNDATA:invalid_argument','get_par function used on class which has not been initated properly');
end

if isempty(this.det_par)
   this.det_par            = load_par(this.loader);        
end
if exist('format','var') && strcnmpi(format,'-hor',4)
   par = get_hor_format(this.par,get(this.loader,'par_file_name'));
else
   par = this.det_par;
end

