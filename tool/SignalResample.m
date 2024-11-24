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
%       'zero' for resample the signal by insert 0.
%       'lowpass' for resample the signal by insert 0 then filtered by 
%       lowpass filter.
%       Please refer to 'interp1' for more detail of other options.
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
    elseif(Signal.SampleRate > SampleRate)
        [UpRate,DownRate] = rat(SampleRate / Signal.SampleRate);
        ResampledSignal = InitAnalogSignal(Signal.ChannelNum, Signal.TimeStart, Signal.TimeEndurance, SampleRate, 'Template', 'As', Signal);
        for index = 1 : Signal.ChannelNum
            TempSignal = resample(Signal.Signal(index,:), UpRate, DownRate);
            ResampledSignal.Signal(index,:) = TempSignal(1:size(ResampledSignal.Signal(index,:), 2));
        end
    else
        ResampleRate = Signal.SampleRate / SampleRate;
        ResampledSignal = InitAnalogSignal(Signal.ChannelNum, Signal.TimeStart, Signal.TimeEndurance, SampleRate, 'Template', 'As', Signal);
        if (strcmp(Mode, 'zero'))
            if ((SampleRate / Signal.SampleRate) ~= round(SampleRate / Signal.SampleRate))
                warning("The resample rate for 'zero' mode is not integer, this may cause error.");
            end
            ResampleIndex = [1 : (ResampledSignal.TimeEndurance * ResampledSignal.SampleRate)] * ResampleRate + (1 - ResampleRate);
            ResampleIndex = (abs(ResampleIndex - round(ResampleIndex)) < (ResampleRate / 2)) .* round(ResampleIndex) + 1;
            ResampleOrigin = [zeros(Signal.ChannelNum, 1) Signal.Signal];
            for index = 1 : Signal.ChannelNum
                ResampledSignal.Signal(index,:) = ResampleOrigin(index, ResampleIndex);
            end
        elseif(strcmp(Mode, 'lowpass'))
            if ((SampleRate / Signal.SampleRate) ~= round(SampleRate / Signal.SampleRate))
                warning("The resample rate for 'zero' mode is not integer, this may cause error.");
            end
            ResampleIndex = [1 : (ResampledSignal.TimeEndurance * ResampledSignal.SampleRate)] * ResampleRate + (1 - ResampleRate);
            ResampleIndex = (abs(ResampleIndex - round(ResampleIndex)) < (ResampleRate / 2)) .* round(ResampleIndex) + 1;
            ResampleOrigin = [zeros(Signal.ChannelNum, 1) Signal.Signal];
            for index = 1 : Signal.ChannelNum
                ResampledSignal.Signal(index,:) = lowpass(ResampleOrigin(index, ResampleIndex), Signal.SampleRate / 2, SampleRate);
            end
        else
            for index = 1 : Signal.ChannelNum
                ResampledSignal.Signal(index,:) = interp1([Signal.Signal(index,:) 0], [1 : (ResampledSignal.TimeEndurance * ResampledSignal.SampleRate)] * ResampleRate + (1 - ResampleRate), Mode);
            end
        end
    end
end

