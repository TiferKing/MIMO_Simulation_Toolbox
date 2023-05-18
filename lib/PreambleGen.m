function [PreambleSignal] = PreambleGen(ChannelNum, Length, SampleRate, PreambleGenerateFx, SignalPreset)
%PreambleGen Generate the frame preamble.
%Introduction:
%   Generate a frame preamble using the specified function.
%Syntax:
%   PreambleSignal = PreambleGen(ChannelNum, Length, SampleRate, PreambleGenerateFx, SignalPreset)
%Description:
%   PreambleSignal = PreambleGen(ChannelNum, Length, SampleRate, PreambleGenerateFx, SignalPreset)
%       returns the frame preamble.
%Input Arguments:
%   ChannelNum: (positive integer scalar)
%       Number of channels.
%   Length: (positive integer scalar)
%       Preamble length.
%   SampleRate: (double)
%       Preamble sample rate in Sa/s.
%   PreambleGenerateFx: (function)
%       Design preamble sequence. The function will called in:
%       PreambleGenerateFx(ChannelNum, Length);
%   SignalPreset: (string)
%       The preset reference voltage, impedance and different pair of
%       signal, please refer to 'InitAnalogSignal' for more detail.
%Output Arguments:
%   PreambleSignal: (AnalogSignal)
%       Generated preamble signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    TimeEndurance = Length / SampleRate;
    PreambleSignal = InitAnalogSignal(ChannelNum, 0, TimeEndurance, SampleRate, SignalPreset);
    PreambleSignal.Signal = PreambleGenerateFx(ChannelNum, Length);
end

