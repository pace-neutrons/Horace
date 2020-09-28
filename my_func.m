function a = my_func(p1, p2, varargin)

p = inputParser();
addOptional(p, 'p3', 0, @isnumeric);
addOptional(p, 'p4', -inf, @isnumeric);
addParameter(p, 'opt1', []);
parse(p, varargin{:});

disp(p1)
disp(p2)
disp(p.Results)
