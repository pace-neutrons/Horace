function [par,this]=get_par(this,format)
% Returns detector parameter data from properly initiated data loader
%
%   >> par = get_par(rundata_instance,['-hor'])
%   >> [par,rundata_instance] = get_par(rundata_instance,['-hor'])
%
% Input:
% ------
%   rundata_instance    Properly initated instance of the rundata class
%   '-hor', '-horace'   Optional parameter to request to return the
%                      detector information in Horace structure,
%                      rather than 6 column array with column:
%
% Output:
% -------
%   par                 Detector parameters
%

if isempty(this.det_par)
    if isempty(this.loader)
        error('RUNDATA:invalid_argument','get_par function used on class which has not been initated properly');
    end
    this.det_par = load_par(this.loader);
end

if exist('format','var') && ~isempty(format) && strncmpi(format,'-hor',4)
    if ~isempty(this.loader)
        filename = this.loader.par_file_name;
    else
        filename = this.par_file_name;
    end
    par = get_hor_format(this.det_par,filename);            
else
    par = this.det_par;
end
