function skipTest(reason)
%skipTest skips a test providing a reason for the skip for logs

%   J. Wilkins

if nargin < 1
    message = 'Test skipped.';
else
    message = reason;
end

throwAsCaller(MException('testSkipped:testSkipped', '%s', message));

end