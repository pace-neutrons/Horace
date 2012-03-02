function  test_rebin_boundaries_description_parse_single
%   empty_is_full_range     true: [] or '' ==> [-Inf,Inf];
%                           false ==> 0
%   range_is_one_bin        true: [x1,x2]  ==> one bin
%                           false ==> [x1,0,x2]
%   array_is_descriptor     true:  interpret array of three or more elements as descripor
%                           false: interpet as actual bin boundaries
%   bin_boundaries          true:  intepret x values as bin boundaries
%                           false: interpret as bin centres

% Rebin
% -----
opt.empty_is_full_range=false;
opt.range_is_one_bin=false;
opt.array_is_descriptor=true;
opt.bin_boundaries=true;

xvals{1}=[];
xvals{2}=0;
xvals{3}=0.2;
xvals{4}=[3,6];
xvals{5}=[5,0.1,Inf];

xvals_bad{1}=-0.2;
xvals_bad{2}=[-3,-0.2,14];
xvals_bad{3}=[-3,0.2,14,4,10];



for i=1:5
    [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=testRebinBoundariesDescriptionParseSingle(opt,xvals{i});
    assertTrue(ok);
    if ok,
        disp(xbounds);
        disp([any_lim_inf,is_descriptor,any_dx_zero]); 
    else
        disp(mess)
    end
end

for i=1:3
    [ok,xbounds,any_lim_inf,is_descriptor,any_dx_zero,mess]=testRebinBoundariesDescriptionParseSingle(opt,xvals_bad{i});
    if i==2
        assertTrue(~ok);
    else
        assertTrue(ok);        
    end
    if ok, disp(xbounds); disp([any_lim_inf,is_descriptor,any_dx_zero]); else disp(mess), end
end
