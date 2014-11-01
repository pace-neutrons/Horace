function [header_out,run_label,ok,mess,hstruct_sort,ind] = testgateway_header_combine(dummy,varargin)
% Routine to test get_sqw - only way to get debugger working properly is to use a gateway function
[header_out,run_label,ok,mess,hstruct_sort,ind] = header_combine(varargin{:});
