%FreeEnvironment
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

if(isunix())
    rmpath('./../lib');
    rmpath('./../probe');
    rmpath('./../tool');
else
    rmpath('.\..\lib');
    rmpath('.\..\probe');
    rmpath('.\..\tool');
end