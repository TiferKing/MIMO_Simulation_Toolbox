function [AnalogSignal] = IQMixing(BaseSignal, CarrierSignal)
%IQMixing Mixing baseband signal to radio band.
%Introduction:
%   IQMixer can modulate the in-phase and quadrature components of a signal
%   independently.
%Syntax:
%   AnalogSignal = IQMixing(BaseSignal, CarrierSignal)
%Description:
%   AnalogSignal = IQMixing(BaseSignal, CarrierSignal)
%       returns the radio signal.
%Input Arguments:
%   BaseSignal: (AnalogSignal)
%       Baseband signal.
%   CarrierSignal: (AnalogSignal)
%       Local-oscillator signal.
%Output Arguments:
%   AnalogSignal: (AnalogSignal)
%       Radio frequecy signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    SampleRate = CarrierSignal.SampleRate;
    IFSignalInput = SignalResample(BaseSignal, CarrierSignal.SampleRate, 'previous');
    if BaseSignal.TimeStart > CarrierSignal.TimeStart
        TimeStart = CarrierSignal.TimeStart;
    else
        TimeStart = BaseSignal.TimeStart;
    end
    if (BaseSignal.TimeStart + BaseSignal.TimeEndurance) > (CarrierSignal.TimeStart + CarrierSignal.TimeEndurance)
        TimeEndurance = (BaseSignal.TimeStart + BaseSignal.TimeEndurance) - TimeStart;
    else
        TimeEndurance = (CarrierSignal.TimeStart + CarrierSignal.TimeEndurance) - TimeStart;
    end
    if BaseSignal.ChannelNum > CarrierSignal.ChannelNum
        ChannelNum = BaseSignal.ChannelNum;
    else
        ChannelNum = CarrierSignal.ChannelNum;
    end
    IFSignal = zeros(ChannelNum, round(TimeEndurance * SampleRate));
    LOSignal = zeros(ChannelNum, round(TimeEndurance * SampleRate));
    IFStartIndex = round((BaseSignal.TimeStart - TimeStart) * SampleRate + 1);
    IFStopIndex = round((BaseSignal.TimeEndurance) * SampleRate + IFStartIndex - 1);
    LOStartIndex = round((CarrierSignal.TimeStart - TimeStart) * SampleRate + 1);
    LOStopIndex = round((CarrierSignal.TimeEndurance) * SampleRate + LOStartIndex - 1);
    IFSignal(:,IFStartIndex : IFStopIndex) = IFSignalInput.Signal;
    LOSignal(:,LOStartIndex : LOStopIndex) = conj(CarrierSignal.Signal);
    % IQ mixing means mixing the I and Q signals independently and then
    % adding them together. However, due to the feature of complex numbers,
    % the LO signal should be conjugated first. For example, if ‘a + bi’ is
    % the IF signal and ‘c + di’ is the LO signal, the output signal should
    % be ‘ac + bdi’. But simply multiplying ‘(a + bi)(c + di)’ will result
    % in ‘ac - bd + (ad + bc)i’ (the real part of it become 'ac - bd'), so
    % the LO signal should be conjugated first.
    
    AnalogSignal = InitAnalogSignal(ChannelNum, TimeStart, TimeEndurance, SampleRate, 'Template','As',BaseSignal);
    AnalogSignal.Signal = real(IFSignal .* LOSignal);
end
