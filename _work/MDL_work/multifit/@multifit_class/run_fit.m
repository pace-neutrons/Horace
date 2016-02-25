function obj = run_fit(obj)

ffun = obj.ffun; fpin = obj.fpin;
if ~obj.foreground_is_local
    ffun = obj.ffun{1};
    fpin = obj.fpin{1};
end

bfun = obj.bfun; bpin = obj.bpin;
if ~obj.background_is_local
    bfun = obj.bfun{1};
    bpin = obj.bpin{1};
end

[ok,mess,parsing,fitdata] = multifit_main(obj.data, ffun, fpin, obj.fpfree, obj.fpbind, bfun, bpin, obj.bpfree, obj.bpbind);
wout = fitdata{1};
fitdat = fitdata{2};
obj.wout = wout;
obj.fitdata = fitdat;
