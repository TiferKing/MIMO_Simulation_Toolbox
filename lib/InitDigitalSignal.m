function [DigitalSignal] = InitDigitalSignal(varargin)
%InitDigitalSignal Initialize a structure containing multi-channel digital signals.
%Introduction:
%   Initialize the struct to contain multi-channel digital signals, along
%   with the different pair, reference voltage etc. It will provide a
%   standard struct to log digital signal and make the analysis or tracing
%   easy. Using the standard digital signal struct will bring much more
%   convenience.
%Syntax:
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, ReferencePreset)
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, 'Custom', ReferenceVoltage, ReferenceImpedance,
%       IsDiffDifferential, Threshold, IdealHigh, IdealLow, IdealHighNeg, IdealLowNeg)
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, 'Template', 'As', TemplateSignal)
%Description:
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, ReferencePreset)
%       returns a blank digital signal with preset arguments.
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, 'Custom', ReferenceVoltage, ReferenceImpedance,
%       IsDiffDifferential, Threshold, IdealHigh, IdealLow, IdealHighNeg, IdealLowNeg)
%       returns a blank digital signal with customized arguments.
%   DigitalSignal = InitDigitalSignal(Channel, TimeStart, TimeEndurance, ClockFrequency, 'Template', 'As', TemplateSignal)
%       returns a blank digital signal with the arguments the same as the 'TemplateSignal'.
%Input Arguments:
%   Channel: (positive integer scalar)
%       Number of channels.
%   TimeStart: (double)
%       The signal start time in second.
%   TimeEndurance: (double)
%       The signal endurance time in second.
%   ClockFrequency: (double)
%       The signal clock in Hz.
%   ReferencePreset: (string)
%       Signal preset reference arguments, it is one of blow:
%       'CMOS': Complementary Metal-Oxide Semiconductor common logic voltage level.
%       'LVCMOS3V3': Low-Voltage CMOS common logic voltage working in 3.3V.
%       'LVCMOS2V5': LVCMOS common logic voltage working in 2.5V.
%       'TTL': Transistor Transistor Logic common logic voltage level.
%       'LVTTL3V3': Low-Voltage TTL common logic voltage working in 3.3V.
%   ReferenceVoltage: (double)
%       Reference voltage of the digital signal in V. For example, the
%       reference voltage is 2.5 means that 1 in the signal represents 2.5V
%       in reality.
%   ReferenceImpedance: (double)
%       Reference impedance of the digital system in Ohm. It means the
%       characteristic impedance of the transmission line used in the
%       simulation system. It is 50Ohm most of the time in modern radio
%       system. Because 50Ohm is the balance of the power capacity and
%       power loss of the transmission line. But other impedances will also
%       be chosen for other reasons (100Ohm for different pair).
%   IsDiffDifferential: (logic)
%       TRUE represents that the digital signal has a different paired
%       signal.
%   Threshold: (double)
%       Logic threshold for 1 or 0 in 'V'. Note: all the voltage inputs
%       below should under the unit 'V', and the transformation for
%       reference will be calculated automatically.
%   IdealHigh: (double)
%       Ideal voltage level for 1;
%   IdealLow: (double)
%       Ideal voltage level for 0;
%   IdealHighNeg: (double)
%       Ideal voltage level for 1 in different pair;
%   IdealLowNeg: (double)
%       Ideal voltage level for 0 in different pair;
%Output Arguments:
%   DigitalSignal: (DigitalSignal)
%       Blank digital signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    DefaultChannel = 1;
    DefaultTimeStart = 0;
    DefaultTimeEndurance = 0;
    DefaultClockFrequency = 1;
    DefaultReferencePreset = 'LVCMOS3V3';
    DefaultReferenceVoltage = 3.3;
    DefaultReferenceImpedance = 50;
    DefaultIsDiffDifferential = false;
    DefaultThreshold = 1.65;
    DefaultIdealHigh = 3.3;
    DefaultIdealLow = 0;
    DefaultIdealHighNeg = 0;
    DefaultIdealLowNeg = 0;
    DefaultTemplate = struct;
    ExpectedReferencePreset = {'CMOS','LVCMOS3V3','LVCMOS2V5','TTL','LVTTL3V3','Custom', 'Template'};
    InPar = inputParser;
    ValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    ValidScalarNoNegNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
    addOptional(InPar,'Channel', DefaultChannel,ValidScalarPosNum);
    addOptional(InPar,'TimeStart',DefaultTimeStart,@isnumeric);
    addOptional(InPar,'TimeEndurance',DefaultTimeEndurance,ValidScalarNoNegNum);
    addOptional(InPar,'ClockFrequency',DefaultClockFrequency,ValidScalarPosNum);
    addOptional(InPar,'ReferencePreset',DefaultReferencePreset,@(x) any(validatestring(x,ExpectedReferencePreset)));
    addOptional(InPar,'ReferenceVoltage',DefaultReferenceVoltage,ValidScalarPosNum);
    addOptional(InPar,'ReferenceImpedance',DefaultReferenceImpedance,ValidScalarPosNum);
    addOptional(InPar,'IsDiffDifferential',DefaultIsDiffDifferential,@(x) islogical(x));
    addOptional(InPar,'Threshold',DefaultThreshold,@(x) isnumeric(x));
    addOptional(InPar,'IdealHigh',DefaultIdealHigh,@(x) isnumeric(x));
    addOptional(InPar,'IdealLow',DefaultIdealLow,@(x) isnumeric(x));
    addOptional(InPar,'IdealHighNeg',DefaultIdealHighNeg,@(x) isnumeric(x));
    addOptional(InPar,'IdealLowNeg',DefaultIdealLowNeg,@(x) isnumeric(x));
    addParameter(InPar,'As',DefaultTemplate,@isstruct);
    parse(InPar,varargin{:});
    
    DigitalSignal = struct;
    DigitalSignal.ChannelNum = InPar.Results.Channel;
    DigitalSignal.TimeStart = InPar.Results.TimeStart;
    DigitalSignal.TimeEndurance = InPar.Results.TimeEndurance;
    DigitalSignal.ClockFrequency = InPar.Results.ClockFrequency;
    DigitalSignal.Signal = zeros(InPar.Results.Channel, round(InPar.Results.TimeEndurance * InPar.Results.ClockFrequency));
    
    if(strcmp(InPar.Results.ReferencePreset, "CMOS"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = false;
        DigitalSignal.ReferenceVoltage = 5;
        DigitalSignal.ReferenceImpedance = 50;
        DigitalSignal.Threshold = 2.5 / 5;
        DigitalSignal.IdealHigh = 5 / 5;
        DigitalSignal.IdealLow = 0 / 5;
        DigitalSignal.IdealHighNeg = 0 / 5;
        DigitalSignal.IdealLowNeg = 0 / 5;
    elseif(strcmp(InPar.Results.ReferencePreset, "LVCMOS3V3"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = false;
        DigitalSignal.ReferenceVoltage = 3.3;
        DigitalSignal.ReferenceImpedance = 50;
        DigitalSignal.Threshold = 1.65 / 3.3;
        DigitalSignal.IdealHigh = 3.3 / 3.3;
        DigitalSignal.IdealLow = 0 / 3.3;
        DigitalSignal.IdealHighNeg = 0 / 3.3;
        DigitalSignal.IdealLowNeg = 0 / 3.3;
    elseif(strcmp(InPar.Results.ReferencePreset, "LVCMOS2V5"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = false;
        DigitalSignal.ReferenceVoltage = 2.5;
        DigitalSignal.ReferenceImpedance = 50;
        DigitalSignal.Threshold = 1.25 / 2.5;
        DigitalSignal.IdealHigh = 2.5 / 2.5;
        DigitalSignal.IdealLow = 0 / 2.5;
        DigitalSignal.IdealHighNeg = 0 / 2.5;
        DigitalSignal.IdealLowNeg = 0 / 2.5;
    elseif(strcmp(InPar.Results.ReferencePreset, "TTL"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = false;
        DigitalSignal.ReferenceVoltage = 5;
        DigitalSignal.ReferenceImpedance = 50;
        DigitalSignal.Threshold = 1.5 / 5;
        DigitalSignal.IdealHigh = 5 / 5;
        DigitalSignal.IdealLow = 0 / 5;
        DigitalSignal.IdealHighNeg = 0 / 5;
        DigitalSignal.IdealLowNeg = 0 / 5;
    elseif(strcmp(InPar.Results.ReferencePreset, "LVTTL3V3"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = false;
        DigitalSignal.ReferenceVoltage = 3.3;
        DigitalSignal.ReferenceImpedance = 50;
        DigitalSignal.Threshold = 1.5 / 3.3;
        DigitalSignal.IdealHigh = 3.3 / 3.3;
        DigitalSignal.IdealLow = 0 / 3.3;
        DigitalSignal.IdealHighNeg = 0 / 3.3;
        DigitalSignal.IdealLowNeg = 0 / 3.3;
    elseif(strcmp(InPar.Results.ReferencePreset, "Custom"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = InPar.Results.IsDiffDifferential;
        DigitalSignal.ReferenceVoltage = InPar.Results.ReferenceVoltage;
        DigitalSignal.ReferenceImpedance = InPar.Results.ReferenceImpedance;
        DigitalSignal.Threshold = InPar.Results.Threshold / InPar.Results.ReferenceVoltage;
        DigitalSignal.IdealHigh = InPar.Results.IdealHigh / InPar.Results.ReferenceVoltage;
        DigitalSignal.IdealLow = InPar.Results.IdealLow / InPar.Results.ReferenceVoltage;
        DigitalSignal.IdealHighNeg = InPar.Results.IdealHighNeg / InPar.Results.ReferenceVoltage;
        DigitalSignal.IdealLowNeg = InPar.Results.IdealLowNeg / InPar.Results.ReferenceVoltage;
    elseif(strcmp(InPar.Results.ReferencePreset, "Template"))
        DigitalSignal.SignalNeg = [];
        DigitalSignal.IsDiffDifferential = InPar.Results.As.IsDiffDifferential;
        DigitalSignal.ReferenceVoltage = InPar.Results.As.ReferenceVoltage;
        DigitalSignal.ReferenceImpedance = InPar.Results.As.ReferenceImpedance;
        DigitalSignal.Threshold = InPar.Results.As.Threshold;
        DigitalSignal.IdealHigh = InPar.Results.As.IdealHigh;
        DigitalSignal.IdealLow = InPar.Results.As.IdealLow;
        DigitalSignal.IdealHighNeg = InPar.Results.As.IdealHighNeg;
        DigitalSignal.IdealLowNeg = InPar.Results.As.IdealLowNeg;
    end
end
