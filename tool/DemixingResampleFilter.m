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

    persistent RFSa;
    persistent BaseSa;
    persistent DesignedFilter;
    if (isempty(RFSa) || isempty(BaseSa) || isempty(DesignedFilter))
        RFSa = RFSampleRate;
        BaseSa = BaseSampleRate;
        [N, Fo, Ao, W] = firpmord([BaseSampleRate / 2, BaseSampleRate] / (RFSampleRate / 2), [1 0], [0.05, 1e-05]);
        DesignedFilter = firpm(N, Fo, Ao, W, {20});
    elseif ((RFSa ~= RFSampleRate) || (BaseSa ~= BaseSampleRate))
        RFSa = RFSampleRate;
        BaseSa = BaseSampleRate;
        [N, Fo, Ao, W] = firpmord([BaseSampleRate / 2, BaseSampleRate] / (RFSampleRate / 2), [1 0], [0.05, 1e-05]);
        DesignedFilter = firpm(N, Fo, Ao, W, {20});
    end
    Filter = DesignedFilter;
end

