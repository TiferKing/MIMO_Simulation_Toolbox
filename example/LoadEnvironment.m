%LoadEnvironment
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

if(isunix())
    addpath('./../lib');
    addpath('./../probe');
    addpath('./../tool');
else
    addpath('.\..\lib');
    addpath('.\..\probe');
    addpath('.\..\tool');
end
