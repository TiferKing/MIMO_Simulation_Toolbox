function [IQSignal] = Modulation(DigitalSignal, Mode, SignalPreset)
%Modulation Convert binary data to IQ signal by modulation.
%Introduction:
%   This function converts signal to IQ symbol by modulation and paired with
%   'Demodulation'.
%Syntax:
%   IQSignal = Modulation(DigitalSignal, Mode, SignalPreset)
%Description:
%   IQSignal = Modulation(DigitalSignal, Mode, SignalPreset)
%       returns the IQ symbol.
%Input Arguments:
%   DigitalSignal: (DigitalSignal)
%       Binary stream signals.
%   Mode: (string)
%       Method of modulation, it is one of blow:
%       'ASK': Amplitude Shift Keying.
%       'BPSK': Binary Phase-Shift Keying.
%       'QPSK': Quadrature Phase Shift Keying.
%       '16QAM': 16-points Quadrature Amplitude Modulation.
%       '64QAM': 64-points Quadrature Amplitude Modulation.
%       '256QAM': 256-points Quadrature Amplitude Modulation.
%       '1024QAM': 1024-points Quadrature Amplitude Modulation.
%   SignalPreset: (string)
%       The preset reference voltage, impedance and different pair of
%       signal, please refer to 'InitAnalogSignal' for more detail.
%Output Arguments:
%   IQSignal: (AnalogSignal)
%       IQ symbol signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    IQSignal = InitAnalogSignal(DigitalSignal.ChannelNum, DigitalSignal.TimeStart, DigitalSignal.TimeEndurance, DigitalSignal.ClockFrequency, SignalPreset);
    if(strcmp(Mode, "ASK"))
        IQSignal.Signal = DigitalSignal.Signal;
    elseif(strcmp(Mode, "BPSK"))
        IQSignal.Signal = DigitalSignal.Signal * 2 - 1;
    elseif (strcmp(Mode, "QPSK"))
        IQSignal.Signal = DigitalSignal.Signal(:,1:2:end) * 2 - 1 + (DigitalSignal.Signal(:,2:2:end) * 2 - 1) * 1i;
        IQSignal.SampleRate = DigitalSignal.ClockFrequency / 2;
    elseif (strcmp(Mode, "16QAM"))
        IQSignal.Signal = ((DigitalSignal.Signal(:,1:4:end) * 2 + DigitalSignal.Signal(:,2:4:end)) * 2 / 3 - 1) + ...
                   ((DigitalSignal.Signal(:,3:4:end) * 2 + DigitalSignal.Signal(:,4:4:end)) * 2 / 3 - 1) * 1i;
        IQSignal.SampleRate = DigitalSignal.ClockFrequency / 4;
    elseif (strcmp(Mode, "64QAM"))
        IQSignal.Signal = ((DigitalSignal.Signal(:,1:6:end) * 4 + DigitalSignal.Signal(:,2:6:end) * 2 + DigitalSignal.Signal(:,3:6:end)) * 2 / 7 - 1) + ...
                   ((DigitalSignal.Signal(:,4:6:end) * 4 + DigitalSignal.Signal(:,5:6:end) * 2 + DigitalSignal.Signal(:,6:6:end)) * 2 / 7 - 1) * 1i;
        IQSignal.SampleRate = DigitalSignal.ClockFrequency / 6;
    elseif (strcmp(Mode, "256QAM"))
        IQSignal.Signal = ((DigitalSignal.Signal(:,1:8:end) * 8 + DigitalSignal.Signal(:,2:8:end) * 4 + DigitalSignal.Signal(:,3:8:end) * 2 + DigitalSignal.Signal(:,4:8:end)) * 2 / 15 - 1) + ...
                   ((DigitalSignal.Signal(:,5:8:end) * 8 + DigitalSignal.Signal(:,6:8:end) * 4 + DigitalSignal.Signal(:,7:8:end) * 2 + DigitalSignal.Signal(:,8:8:end)) * 2 / 15 - 1) * 1i;
        IQSignal.SampleRate = DigitalSignal.ClockFrequency / 8;
    elseif (strcmp(Mode, "1024QAM"))
        IQSignal.Signal = ((DigitalSignal.Signal(:,1:10:end) * 16 + DigitalSignal.Signal(:,2:10:end) * 8 + DigitalSignal.Signal(:,3:10:end) * 4 + ...
                   DigitalSignal.Signal(:,4:10:end) * 2 + DigitalSignal.Signal(:,5:10:end)) * 2 / 31 - 1) + ...
                   ((DigitalSignal.Signal(:,6:10:end) * 16 + DigitalSignal.Signal(:,7:10:end) * 8 + DigitalSignal.Signal(:,8:10:end) * 4 + ...
                   DigitalSignal.Signal(:,9:10:end) * 2 + DigitalSignal.Signal(:,10:10:end)) * 2 / 31 - 1) * 1i;
        IQSignal.SampleRate = DigitalSignal.ClockFrequency / 10;
    end
end

