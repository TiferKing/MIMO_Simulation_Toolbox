function [AnalogSignal] = InitAnalogSignal(varargin)
%InitAnalogSignal Initialize a structure containing multi-channel analog signals.
%Introduction:
%   Initialize the struct to contain multi-channel analog signals, along
%   with the reference voltage, impedance, etc. It will provide a standard
%   struct to log analog signal and make the analysis or tracing easy.
%   Using the standard analog signal struct will bring much more
%   convenience.
%Syntax:
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, ReferencePreset)
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, 'Custom', ReferenceVoltage, ReferenceImpedance)
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, 'Template', 'As', TemplateSignal)
%Description:
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, ReferencePreset)
%       returns a blank analog signal.
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, 'Custom', ReferenceVoltage, ReferenceImpedance)
%       returns a blank analog signal with customized arguments.
%   AnalogSignal = InitAnalogSignal(Channel, TimeStart, TimeEndurance, SampleRate, 'Template', 'As', TemplateSignal)
%       returns a blank analog signal with the arguments the same as the 'TemplateSignal'.
%Input Arguments:
%   Channel: (positive integer scalar)
%       Number of channels.
%   TimeStart: (double)
%       The signal start time in second.
%   TimeEndurance: (double)
%       The signal endurance time in second.
%   SampleRate: (double)
%       The signal sample rate in Sa/s.
%   ReferencePreset: (string)
%       Signal preset reference arguments, it is one of blow:
%       '50Ohm-2.5V': Signal with 2.5V reference voltage and 50Ohm impedance.
%       '50Ohm-3.3V': Signal with 3.3V reference voltage and 50Ohm impedance.
%       '50Ohm-1V': Signal with 1V reference voltage and 50Ohm impedance.
%   ReferenceVoltage: (double)
%       Reference voltage of the analog signal in V. For example, the
%       reference voltage is 2.5 means that 1 in the signal represents 2.5V
%       in reality.
%   ReferenceImpedance: (double)
%       Reference impedance of the analog system in Ohm. It means the
%       characteristic impedance of the transmission line used in the
%       simulation system. It is 50Ohm most of the time in modern radio
%       system. Because 50Ohm is the balance of the power capacity and
%       power loss of the transmission line. But other impedances will also
%       be chosen for other reasons (75Ohm for lowest power loss).
%Output Arguments:
%   AnalogSignal: (AnalogSignal)
%       Blank analog signal.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    DefaultChannel = 1;
    DefaultTimeStart = 0;
    DefaultTimeEndurance = 0;
    DefaultSampleRate = 1;
    DefaultReferencePreset = '50Ohm-2.5V';
    DefaultReferenceVoltage = 2.5;
    DefaultReferenceImpedance = 50;
    DefaultTemplate = struct;
    ExpectedReferencePreset = {'50Ohm-2.5V','50Ohm-3.3V','50Ohm-1V','Custom','Template'};
    InPar = inputParser;
    ValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    ValidScalarNoNegNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
    addOptional(InPar,'Channel', DefaultChannel,ValidScalarPosNum);
    addOptional(InPar,'TimeStart',DefaultTimeStart,@isnumeric);
    addOptional(InPar,'TimeEndurance',DefaultTimeEndurance,ValidScalarNoNegNum);
    addOptional(InPar,'SampleRate',DefaultSampleRate,ValidScalarPosNum);
    addOptional(InPar,'ReferencePreset',DefaultReferencePreset,@(x) any(validatestring(x,ExpectedReferencePreset)));
    addOptional(InPar,'ReferenceVoltage',DefaultReferenceVoltage,ValidScalarPosNum);
    addOptional(InPar,'ReferenceImpedance',DefaultReferenceImpedance,ValidScalarPosNum);
    addParameter(InPar,'As',DefaultTemplate,@isstruct);
    parse(InPar,varargin{:});
    
    AnalogSignal = struct;
    SignalLength = round(InPar.Results.TimeEndurance * InPar.Results.SampleRate);
    AnalogSignal.ChannelNum = InPar.Results.Channel;
    AnalogSignal.TimeStart = InPar.Results.TimeStart;
    AnalogSignal.TimeEndurance = SignalLength * (1 / InPar.Results.SampleRate);
    AnalogSignal.SampleRate = InPar.Results.SampleRate;
    AnalogSignal.Signal = zeros(InPar.Results.Channel, SignalLength);
    
    if(strcmp(InPar.Results.ReferencePreset, "50Ohm-2.5V"))
        AnalogSignal.ReferenceVoltage = 2.5;
        AnalogSignal.ReferenceImpedance = 50;
    elseif(strcmp(InPar.Results.ReferencePreset, "50Ohm-3.3V"))
        AnalogSignal.ReferenceVoltage = 3.3;
        AnalogSignal.ReferenceImpedance = 50;
    elseif(strcmp(InPar.Results.ReferencePreset, "50Ohm-1V"))
        AnalogSignal.ReferenceVoltage = 1;
        AnalogSignal.ReferenceImpedance = 50;
    elseif(strcmp(InPar.Results.ReferencePreset, "Custom"))
        AnalogSignal.ReferenceVoltage = InPar.Results.ReferenceVoltage;
        AnalogSignal.ReferenceImpedance = InPar.Results.ReferenceImpedance;
    elseif(strcmp(InPar.Results.ReferencePreset, "Template"))
        AnalogSignal.ReferenceVoltage = InPar.Results.As.ReferenceVoltage;
        AnalogSignal.ReferenceImpedance = InPar.Results.As.ReferenceImpedance;
    end
end

