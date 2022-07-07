function obj = set_consistent_array(obj,field_name,value)
% set consistent data array
% and break connection between the class and data file -- currently
% disabled
%
%

if isempty(value)
    if isempty(obj.file_name)
        obj=obj.delete();
    else
        obj.S_=[];
        obj.ERR_=[];
    end
    return
end

obj.(field_name) = value;
%this.file_name_ = '';

if strcmp(field_name,'en_')
    %    sig_size = [];
    obj.en_ = value(:);
    %     if ~isempty(obj.S_)
    %         sig_size = size(obj.S_);
    %     else
    %         if ~isempty(obj.ERR_)
    %             sig_size = size(obj.ERR_);
    %         end
    %     end
    %     if ~isempty(sig_size)
    %         if size(value,1)== sig_size(1) % assigned energy points. Needs conversion in histogram.
    %            % DO we need to change signal, considering change in the binning?
    %             bins = value(2:end)-value(1:end-1);
    %             edges = [(value(1:end-1)-0.5*bins);value(end)-0.5*bins(end);(value(end)+0.5*bins(end))];
    %             obj.en_ = edges;
    %             obj.en_ = value;
    %         end
    %    end
else
    obj.n_detindata_ = size(value,2);
end
if obj.do_check_combo_arg_
    obj = obj.check_combo_arg();
end

