function c = lexcmp(s1,s2)
% LEXCMP  C-style array/string comparison (by lexical order)
% usage: lexcmp(s1,s2)
%
% If S1 and S2 are strings, LEXCMP(S1,S2) returns:
%    -1,  S1 < S2
%     0,  S1 = S2
%     1,  S1 > S2
% where S1 and S2 are compared by the first element that differs.
%
% S1 and S2 can be numeric or logical arrays with possibly different
% lengths and possibly containing inf/NaN values (treating pairs of NaN
% values as equal and all other values less than NaN, as per the convention
% of the built-in version of SORT).
%
% S1 and S2 can theoretically be arrays of any objects for which SIGN,
% MINUS, ISINF and ISNAN are defined, e.g. fractions (see below).
%
% If S1 and S2 are cell arrays with the same number of elements, they are
% compared element-by-element.  If one is a cell array and the other is
% not, then each element of one is compared to the other.
%
% Example:
%   lexcmp('abc','abc') %  0
%   lexcmp('abc','abd') % -1
%   lexcmp('a','ab')    % -1
%   lexcmp(nan,nan)     %  0
%   lexcmp(1:2,1:3)     % -1
%   lexcmp(fr(1,3),fr(1,2)) % -1 (using Fractions Toolbox)
%
% Implementation note:
%
% The core function could be implemented more concisely if vectorized
% rather than looped, but tests indicated that loops seem to be faster on
% average (in the original version with no inf/nan checking).  The biggest
% performance gains occur when the strings are long and differ near the
% beginning, as the loop exits early and avoids unnecessary comparisons;
% similarly when the arrays are non-numeric objects with significant
% overhead per comparison.  To get any further performance gains, the best
% option would probably be to translate the core function to MEX.
%
%	See also STRCMP (built-in), STRCMPC (FEX #3987), Fractions Toolbox (FEX #24878).

% Ben Petschel 19/2/2009
%
% Version history:
%   19/2/2009 - First release.  The core function is based on S.Helsen's
%     STRCMPC (http://www.mathworks.com/matlabcentral/fileexchange/3987).
%     The find part has been replaced with a loop which is slightly faster
%     in the current version of MATLAB.
%   14/9/2009 - Updated lexcmp_core to allow infinite or NaN values
%     and added some examples to the help text.

% Copyright (c) 2009, Ben Petschel
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.
% 


% decide whether to compare directly or element-by-element
if iscell(s1)
  if iscell(s2)
    if numel(s1)==numel(s2),
      % compare element by element
      c=zeros(size(s1));
      for i=1:numel(s1),
        c(i)=lexcmp_core(s1{i},s2{i});
      end;
    else
      error('lexcmp:cellsize','cell array inputs must have same number of elements');
    end;
  elseif isvector(s2)
    % compare each element of s1 with s2
    c=zeros(size(s1));
    for i=1:numel(s1),
      c(i)=lexcmp_core(s1{i},s2);
    end;
  else
    error('lexcmp:inclass','input s2 must be a cell or an array');
  end;
elseif isvector(s1)
  if iscell(s2)
    % compare s1 with each element of s2
    c=zeros(size(s2));
    for i=1:numel(s2),
      c(i)=lexcmp_core(s1,s2{i});
    end;
  elseif isvector(s2)
    % compare s1 and s2 directly
    c=lexcmp_core(s1,s2);
  else
    error('lexcmp:inclass','input s2 must be a cell or an array');
  end;
else
  error('lexcmp:inclass','input s1 must be a cell or an array');
end

end % main function lexcmp(...)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=lexcmp_core(s1,s2)
% helper function for lexcmp

L=min(numel(s1),numel(s2));
c=0;
i=1;
% find the first place where the strings differ
while (c==0) && (i<=L)
  c=sign(s1(i)-s2(i));
  if isnan(c)
    % have (inf,inf) or (-inf,-inf) or (x,nan) or (nan,x)
    if isinf(s1(i)) && isinf(s2(i))
      % case (inf,inf) or (-inf,-inf)
      c=0;
    else
      % use convention x<nan unless x is nan
      % (nan,nan) -> 0,  (x,nan) -> -1,  (nan,x) -> 1
      c=isnan(s1(i))-isnan(s2(i));
    end;
  end;
  i=i+1;
end;
if c==0
  % strings agree so far -> compare on lengths
  c=sign(numel(s1)-numel(s2));
end;

end % helper function lexcmp_core
