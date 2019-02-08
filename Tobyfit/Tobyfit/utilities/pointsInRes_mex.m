function pointsInRes_mex(varargin)
% Compile and/or test the mex functions for determining in-resolution
% points

% TODO: parse the input(s)

compile=true;
test=true;

if compile
    oldpwd = pwd();
    % Locate the directory containting the C++ source files
    src = strcat(fileparts(which('pointsInRes_mex')),filesep,'mex',filesep);
    cd(src);
    if ispc()
        opt={'COMPFLAGS=$COMPFLAGS /openmp','LINKFLAGS=$LINKFLAGS /nodefaultlib:vcomp "$MATLABROOT\bin\win64\libiomp5md.lib"'};
    elseif ismac()
        opt={'COMPFLAGS="/openmp $COMPFLAGS"','CXXFLAGS=$CXXFLAGS -fopenmp -pthread'};
    else
        opt={'CXXFLAGS=$CXXFLAGS -fopenmp -pthread','LDFLAGS=$LDFLAGS -fopenmp'};
    end
    tomex = {'cppPointsInResPix.cpp','cppPointsInResRunPix.cpp'};
    for i=1:length(tomex)
        mex(tomex{i},opt{:});
    end
    cd(oldpwd);
end
if test
    cppPointsInResPix();
    cppPointsInResRunPix();
end