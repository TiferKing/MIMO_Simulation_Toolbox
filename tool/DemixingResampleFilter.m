function [Filter] = DemixingResampleFilter(RFSampleRate, BaseSampleRate)
%DemixingResampleFilter Design demixing downsample filter.
%Introduction:
%   This function designs the downsample filter utilized in demixing the
%   signals to avoid spectral aliasing.
%Syntax:
%   Filter = DemixingResampleFilter(RFSampleRate, BaseSampleRate)
%Description:
%   Filter = DemixingResampleFilter(RFSampleRate, BaseSampleRate)
%       returns the designed filter.
%Input Arguments:
%   RFSampleRate: (double)
%       RF signal sample rate in Sa/s.
%   BaseSampleRate: (double)
%       Baseband signal sample rate in Sa/s.
%Output Arguments:
%   Filter: (matrix)
%       Filter coefficient.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    [N, Fo, Ao, W] = firpmord([BaseSampleRate / 2, BaseSampleRate] / (RFSampleRate / 2), [1 0], [0.05, 1e-05]);
    Filter = firpm(N, Fo, Ao, W, {20});
end

