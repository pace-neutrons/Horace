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
if isempty(this.det_par)
    if isempty(this.loader)
        error('RUNDATA:invalid_argument','get_par function used on class which has not been initated properly');
    end
    this.det_par            = load_par(this.loader);        
end

if exist('format','var') && ~isempty(format) && strncmpi(format,'-hor',4)
   if ~isempty(this.loader)
       filename = get(this.loader,'par_file_name');
   else
       filename = this.par_file_name;
   end
   par = get_hor_format(this.det_par,filename);
else
   par = this.det_par;
end

