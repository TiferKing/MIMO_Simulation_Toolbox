function [Delay] = ProbeDelay(SignalA, SignalB, Title)
%ProbeBitError A probe that detects delay between two signals.
%Introduction:
%   Get the delay between two signals.
%Syntax:
%   Delay = ProbeDelay(SignalA, SignalB)
%   Delay = ProbeDelay(SignalA, SignalB, Title)
%Description:
%   Delay = ProbeDelay(SignalA, SignalB)
%       returns the signal delay.
%   Delay = ProbeDelay(SignalA, SignalB, Title)
%       display 'Delay' after 'Title' on console.
%Input Arguments:
%   SignalA: (Signal)
%       One signal.
%   SignalB: (Signal)
%       Another signal.
%   Title: (string)
%       Probe display title.
%Output Arguments:
%   Delay: (double)
%       The delay time in second.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    Delay = SignalB.TimeStart - SignalA.TimeStart;
    if(exist('Title','var'))
        DisplayString = [Title ' = ' num2str(Delay) ' s.'];
        disp(DisplayString);
    end
end

