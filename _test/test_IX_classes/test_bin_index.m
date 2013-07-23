function test_bin_index
% Test of bin_index for some trying input arguments
%
%   >> test_bin_index
%
% With each of the xbounds, x combinations, check that indx makes sense for
% both of the values of the input argument 'inclusive'

banner_to_screen(mfilename)

xbounds=[1,4,5];
x=[0.9,1,1.1,4,5,6];    ibin_t=[0,1,1,2,2,3];       ibin_f=[0,1,1,2,3,3];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[15,16,17];           ibin_t=[3,3,3];             ibin_f=[3,3,3];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[2,3,3,4,4,4,5,5];    ibin_t=[1,1,1,2,2,2,2,2];   ibin_f=[1,1,1,2,2,2,3,3];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end


xbounds=[1,4,4,5];
x=[2,3,3,4,4,4,5,5];    ibin_t=[1,1,1,3,3,3,3,3];   ibin_f=[1,1,1,3,3,3,4,4];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end


xbounds=[1,4,5];
x=[4.2,4.3,4.7];        ibin_t=[2,2,2];             ibin_f=[2,2,2];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[2,5,5,5];            ibin_t=[1,2,2,2];           ibin_f=[1,3,3,3];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[2,4,4,4];            ibin_t=[1,2,2,2];           ibin_f=[1,2,2,2];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[4,4,4];              ibin_t=[2,2,2];             ibin_f=[2,2,2];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[5,5,5];              ibin_t=[2,2,2];             ibin_f=[3,3,3];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end


xbounds=[1,2,3,4,5];
x=[1.3,2,4,6];          ibin_t=[1,2,4,5];           ibin_f=[1,2,4,5];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end
x=[1.3,2,4,5];          ibin_t=[1,2,4,4];           ibin_f=[1,2,4,5];
[ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f); if ~ok, error(mess), end

disp(' ')
disp('All OK')
disp(' ')

%------------------------------------------------------------------------------
function [ok,mess]=all_ok(x,xbounds,ibin_t,ibin_f)
if ~isequal(ibin_t,bin_index(x,xbounds,true))
    ok=false;
    mess='Unexpected result for inclusive==true';
elseif ~isequal(ibin_f,bin_index(x,xbounds,false))
    ok=false;
    mess='Unexpected result for inclusive==false';
else
    ok=true;
    mess='';
end
