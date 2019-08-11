function strip_instrument_and_sample (file_in, file_out)
% Remove instrument and sample information from the sqw objects in a .mat file
%
%   >> strip_instrument_and_sample (file_in)
%   >> strip_instrument_and_sample (file_in, file_out)

S = load (file_in);

nam = fieldnames(S);
for i=1:numel(nam)
    if isa(S.(nam{i}),'sqw')
        S.(nam{i}) = strip_instrument_and_sample_single (S.(nam{i}));
    end
end

if nargin==1
    save(file_in, '-struct', 'S');
else
    save(file_out, '-struct', 'S');
end

%------------------------------
function Sout = strip_instrument_and_sample_single (S)
Sout = S;
for iobj = 1:numel(Sout)
    if ~iscell(Sout(iobj).header)
        %disp('Ooerr!')
        Sout(iobj).header.instrument = struct();
        Sout(iobj).header.sample = struct();
    else
        h = Sout(iobj).header;
        for i=1:numel(h)
            %disp(num2str(i))
            h{i}.instrument = struct();
            h{i}.sample = struct();
        end
        Sout(iobj).header = h;
    end
end
