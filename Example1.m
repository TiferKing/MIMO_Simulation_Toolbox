%Example1 OAM communications in ideal channel.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

LoadEnvironment;

%% Simulation config
DataLegth = 800;
ChannelNum = 8;
ChannelNoise = -10;
FramePreambleLength = 61;
SequenceMode = "prbs31";
AnalogSignalPreset = "50Ohm-2.5V";
DigitalSignalPreset = "LVCMOS3V3";
BaseAnalogSampleRate = 1e9;
BaseBitRate = 4e8;
BaseModulationMode = "QPSK";
BaseShapingBeta = 0.25;
BaseShapingSpan = 8;
BaseOrthogonalPreset = "OAM";
CarrierFrequency = 5.8e9;
CarrierSampleRate = 1000e9;
MaxSimulationFrequency = CarrierFrequency * 5;
MaxChannelImpulseEndurance = 12 / (pi * MaxSimulationFrequency);

%% Simulation Flow
BaseData = DigitalSignalGen(ChannelNum, DataLegth, BaseBitRate, SequenceMode, DigitalSignalPreset);
IQBase = Modulation(BaseData, BaseModulationMode, AnalogSignalPreset);
OrthogonalBase = OrthogonalMatrixLoad(IQBase, BaseOrthogonalPreset);
FramePreamble = PreambleGen(ChannelNum, FramePreambleLength, IQBase.SampleRate, @ZadoffChuGen, AnalogSignalPreset);
FrameSignal = FrameEncapsulate(OrthogonalBase, FramePreamble);
ShapingFilter = ShapingFilterDesign(BaseShapingBeta, BaseShapingSpan, BaseAnalogSampleRate, IQBase.SampleRate);
ShapedSignal = ChannelShaping(FrameSignal, ShapingFilter, BaseAnalogSampleRate);
CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, ShapedSignal.TimeStart, ShapedSignal.TimeEndurance, AnalogSignalPreset);
TransmiteSignal = IQMixing(ShapedSignal, CarrierSignal);

TxPower = ProbeSignalPower(TransmiteSignal);
dispstr = ['TxPower = ' num2str(pow2db(TxPower)) 'dBW'];
disp(dispstr);

ChannelImpulse = InitChannelImpulseResponse(ChannelNum, ChannelNum, 0, MaxChannelImpulseEndurance, CarrierSampleRate, 0, MaxSimulationFrequency, 'Gaussian');
RecivedSignal = Channel(TransmiteSignal, ChannelImpulse, ChannelNoise);
RxPower = ProbeSignalPower(RecivedSignal);
dispstr = ['RxPower = ' num2str(pow2db(RxPower)) 'dBW'];
disp(dispstr);

CarrierSignal = CarrierGen(CarrierFrequency, ChannelNum, CarrierSampleRate, RecivedSignal.TimeStart, RecivedSignal.TimeEndurance, AnalogSignalPreset);
BaseSignal = IQDemixing(RecivedSignal, CarrierSignal, BaseAnalogSampleRate, @DemixingResampleFilter);
[PayloadSiganl, ChannelEstimation] = FrameDecapsulate(BaseSignal, FramePreamble, ShapingFilter);
DeorthogonalBase = OrthogonalMatrixUnload(PayloadSiganl, BaseOrthogonalPreset);
SymbolSignal = BaseSymbolSample(DeorthogonalBase, IQBase.SampleRate);
RecivedData = Demodulation(SymbolSignal, BaseModulationMode, DigitalSignalPreset);
ErrorRate = ProbeBitError(BaseData, RecivedData);
dispstr = ['ErrorRate = ' num2str(ErrorRate)];
disp(dispstr);

%% Data visualization
t = tiledlayout(ChannelNum,1);
for index = 1: ChannelNum
    nexttile;
    Step = (BaseAnalogSampleRate / IQBase.SampleRate);
    Start = 1 + FramePreambleLength * Step;
    Stop = DataLegth * (BaseAnalogSampleRate / BaseBitRate) + FramePreambleLength * Step;
    stem([Start : Step : Stop], real(IQBase.Signal(index,:)), 'kx');
    hold on;
    plot(real(ShapedSignal.Signal(index,:)));
end
t2 = figure;
plot(TransmiteSignal.Signal(1,:));
t3 = figure;
plot(RecivedSignal.Signal(1,:));
t4 = figure;
ChannelImpulseFig = reshape(ChannelImpulse.Signal(1,1,:),1,[]);
plot(ChannelImpulseFig);
t5 = figure;
plot(real(BaseSignal.Signal(1,:)));
t6 = tiledlayout(ChannelNum,1);
for index = 1: ChannelNum
    nexttile;
    plot(real(DeorthogonalBase.Signal(index,:)));
end
t7 = figure;
plot(IQBase.Signal,'.');
t8 = figure;
plot(DeorthogonalBase.Signal(index,:),'.');
t9 = figure;
plot(SymbolSignal.Signal,'.');

FreeEnvironment;