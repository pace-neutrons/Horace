function [data_range,job_disp,jd_initialized,argi]= parse_additional_input4_join_sqw_(varargin)
% parse input to extract pixel range and initialized job dispatcher if any
% of them provided as input arguments
%
data_range = PixelDataBase.EMPTY_RANGE;
job_disp = [];
jd_initialized = false;
argi = {};
%
if isempty(varargin)
    return;
end

is_jd = cellfun(@(x)(isa(x,'JobDispatcher')),varargin,'UniformOutput',true);
if any(is_jd)
    job_disp = varargin(is_jd);
    if numel(job_disp) >1
        error('HORACE:write_nsqw_to_sqw:invalid_argument',...
            'only one instance of JobDispatcher can be provided as input');
    else
        job_disp  = job_disp{1};
    end
    if ~job_disp.is_initialized
        error('HORACE:write_nsqw_to_sqw:invalid_argument',...
            ['Only initialized JobDispatcher is currently supported',...
            ' as input for write_nsqw_to_sqw.',...
            ' Use "parallel" option to combine files in parallel']);
    end
    jd_initialized = true;
    varargin = varargin(~is_jd);
end
%
if isempty(varargin)
    return;
end
%
is_range = cellfun(@(x)(isequal(size(x),[2,9])),varargin,'UniformOutput',true);
if ~any(is_range)
    argi = varargin(~is_range);
    return;
end
if sum(is_range) > 1
    error('HORACE:write_nsqw_to_sqw:invalid_argument',...
        ['More then one variable in input arguments is interpreted as range.',...
        ' This is not currently supported'])
end
data_range  = varargin{is_range};
argi = varargin(~is_range);