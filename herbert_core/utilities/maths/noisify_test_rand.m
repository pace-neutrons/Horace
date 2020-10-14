function vals = noisify_test_rand(n)
%--------------------------------------------------
% This function creates a simple deterministic series
% of numbers which can be substituted for a true pseudo-random
% number generator to enable by-eye checking of the random
% noise addition (via noisify( to the signal. It can
% substitute for randn in the Herbert noisify method.
%
% This function is designed to accumulate the "pseudo-
% random" numbers across multiple calls - one for each
% page of a paged sqw object. An external global flag
% initialises these numbers, and an internal persistent
% number keeps track of where this process has got to.
%
% Input:
%     n - size of the signal vector for which the noise
%         is being generated.
% The global flag is expected to be acceptable in a test
% though not in production code.
%--------------------------------------------------

% external global flag to signal that this pseudo-random
% number distribution needs to be initialised if true.
global noisify_test_rand_init;
% internal number tracking where in the generation of
% the sequence we have got to.
persistent got_to;

% On initialisation the flag is reset false and the number
% sequence tracker is initialised to 1
if noisify_test_rand_init
    noisify_test_rand_init = false;
    got_to = 1;
end

% the size vector of the signal which is passed in as the argument
% is a 1xsize vector - the actual size is extracted from the second 
% element.
n = n(2);

% The values generated are an ascending sequence of increment one in 
% the range [0:999]*1e-3. The sequence starts with the previously used last
% value; the values in the range are generated with mod(:,1000).
% It is expected that the signal values are in the range [0:999]; the
% resulting signal+noise sequence is 1.001, 2.002, 3.003 etc up to
% ... 998.998, 999.999, 0, 1.001 and repeating.
vals = mod((got_to:got_to+n-1),1000).*1e-3;

% the sequence tracker is moved to the end of the positions processed.
got_to = got_to+n;

end

