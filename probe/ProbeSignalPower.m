function [TotalPowerRMS, ChannelPowerRMS, TotalPowerPeak, ChannelPowerPeak] = ProbeSignalPower(Signal, Title)
%ProbeBitError A probe that detects signal power.
%Introduction:
%   Calculate signal power.
%Syntax:
%   TotalPowerRMS = ProbeSignalPower(Signal)
%   [TotalPowerRMS, ChannelPowerRMS, TotalPowerPeak, ChannelPowerPeak] = ProbeSignalPower(Signal)
%   [ ___ ] = ProbeSignalPower(Signal, Title)
%Description:
%   TotalPowerRMS = ProbeSignalPower(Signal)
%       returns the rms power of signal.
%   [TotalPowerRMS, ChannelPowerRMS, TotalPowerPeak, ChannelPowerPeak] = ProbeSignalPower(Signal)
%       returns the rms power of signals, the rms powers in each channel,the
%       peak power of signals, the peak powers in each channel.
%   [ ___ ] = ProbeSignalPower(Signal, Title)
%       display all total power after 'Title' on console.
%Input Arguments:
%   Signal: (Signal)
%       Input signals.
%   Title: (string)
%       Probe display title.
%Output Arguments:
%   TotalPowerRMS: (double)
%       The rms power of signals for all channels.
%   ChannelPowerRMS: (vector)
%       The rms power of signals in each channel.
%   TotalPowerPeak: (double)
%       The peak power of signals for all channels.
%   ChannelPowerPeak: (vector)
%       The peak power of signals in each channel.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ChannelPowerRMS = sum((abs(Signal.Signal) * Signal.ReferenceVoltage) .^ 2 / Signal.ReferenceImpedance, 2) / size(Signal.Signal, 2);
    TotalPowerRMS = sum(ChannelPowerRMS);
    ChannelPowerPeak = sum((max(abs(Signal.Signal), [], 2) * Signal.ReferenceVoltage) .^ 2 / Signal.ReferenceImpedance, 2);
    TotalPowerPeak = sum(ChannelPowerPeak);
    if(exist('Title','var'))
        DisplayString = [Title '_PowerRMS = ' num2str(pow2db(TotalPowerRMS)) 'dBW'];
        disp(DisplayString);
        DisplayString = [Title '_PowerPeak = ' num2str(pow2db(TotalPowerPeak)) 'dBW'];
        disp(DisplayString);
    end
end

