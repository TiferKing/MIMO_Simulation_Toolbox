function [ResampledSignal] = SignalResample(Signal, SampleRate, Mode)
%SignalResample Resample signals.
%Introduction:
%   This function resample signals using 'interp1' that contains more
%   method than 'resample'.
%Syntax:
%   ResampledSignal = SignalResample(Signal, SampleRate, Mode)
%Description:
%   ResampledSignal = SignalResample(Signal, SampleRate, Mode)
%       returns the resampled signals.
%Input Arguments:
%   Signal: (AnalogSignal)
%       Original signals.
%   SampleRate: (double)
%       Resample target sample rate in Sa/s.
%   Mode: (string)
%       Please refer to 'interp1' for more detail.
%Output Arguments:
%   ResampledSignal: (AnalogSignal)
%       Resampled signals.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    if (Signal.SampleRate == SampleRate)
        ResampledSignal = Signal;
    else
        ResampleRate = Signal.SampleRate / SampleRate;
        ResampledSignal = InitAnalogSignal(Signal.ChannelNum, Signal.TimeStart, Signal.TimeEndurance, SampleRate, 'Template', 'As', Signal);
        for index = 1 : Signal.ChannelNum
            ResampledSignal.Signal(index,:) = interp1([Signal.Signal(index,:) 0], [1 : ResampleRate : size(Signal.Signal, 2) + 1 - ResampleRate], Mode);
        end
    end
end

