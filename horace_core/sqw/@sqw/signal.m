function wout=signal(w, name)
% DEPRECATED; USE coordinates_calc
% Replace the sqw's signal and variance data with coordinate values (see below)

% Original author: T.G.Perring

warning('HORACE:signal:deprecated', ...
        'signal has been deprecated in favour of `coordinates_calc`');

wout = coordinates_calc(w, name);

end
