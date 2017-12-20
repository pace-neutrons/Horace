function test_bind_parse_2

%[ok,mess,ipb,ifunb,ipf,ifunf,R] = bind_parse_array (np,nbp,isfore,bnd)

%---------------------------------
bnd = [7,3,2,2,NaN];
[ok,mess,ipb,ifunb,ipf,ifunf,R] = testgateway(mfclass,'bind_parse', [4,5,9,6], [5,3,1,1], true, [], bnd);
assert_ok (ok, mess, [ipb,ifunb,ipf,ifunf,R], bnd)

%---------------------------------
bnd = [...
    7,3,2,-2,NaN;...
    2,4,2,4,NaN;...
    ];
[ok,mess,ipb,ifunb,ipf,ifunf,R] = testgateway(mfclass,'bind_parse', [4,5,9,6], [5,3,1,1], true, [], bnd);
res = [7,3,2,-2,NaN];
assert_ok (ok, mess, [ipb,ifunb,ipf,ifunf,R], res)

%---------------------------------
bnd = [...
    7,3,7,3,NaN;...
    2,4,2,4,NaN;...
    ];
[ok,mess,ipb,ifunb,ipf,ifunf,R] = testgateway(mfclass,'bind_parse', [4,5,9,6], [5,3,1,1], true, [], bnd);
res = zeros(0,5);
assert_ok (ok, mess, [ipb,ifunb,ipf,ifunf,R], res)

%---------------------------------
bnd = [7,3,2,-3,NaN];
[ok,mess,ipb,ifunb,ipf,ifunf,R] = testgateway(mfclass,'bind_parse', [4,5,9,6], [5,3,1,1], true, [], bnd);
assert_bad (ok, mess, [ipb,ifunb,ipf,ifunf,R])


%----------------------------------------------------------------------------------------------------------
function assert_ok (ok,mess,out,out_ref)
if ok
    if ~isequaln(out,out_ref)
        disp(out_ref)
        disp(out)
        error('Output doesnt match expectation')
    end
else
    error(mess)
end

function assert_bad (ok,mess,out)
if ok
    disp(out)
    error('Should have failed')
end
