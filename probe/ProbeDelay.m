function [Delay] = ProbeDelay(SignalA, SignalB)
%ProbeBitError A probe that detects delay between two signals.
%Introduction:
%   Get the delay between two signals.
%Syntax:
%   Delay = ProbeDelay(SignalA, SignalB)
%Description:
%   Delay = ProbeDelay(SignalA, SignalB)
%       returns the signal delay.
%Input Arguments:
%   SignalA: (Signal)
%       One signal.
%   SignalB: (Signal)
%       Another signal.
%Output Arguments:
%   Delay: (double)
%       The delay time in second.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    Delay = SignalB.TimeStart - SignalA.TimeStart;
end

