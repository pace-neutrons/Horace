function test_unique_extra(A)

% Intrinsic
bigtic;
[C_ref, ia_ref, ic_ref] = unique(A);
bigtoc

% Homebrew
bigtic;
[C,ia,ic,ix,nelmts,nbeg,nend] = unique_extra(A);
bigtoc

if ~(isequal(C_ref,C))
    error('Error: C')
end
if ~(isequal(ia_ref,ia))
    error('Error: ia')
end
% if ~(isequal(ic_ref,ic))
%     error('Error: ic')
% end

