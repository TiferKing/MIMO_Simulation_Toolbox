%OAMFocusingExample 
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

LoadEnvironment;

%% Config
TxChannelNum = 16;
TxAntennaRadius = 1;
TxBFElementNum = 19;
TxBFDistance = 0.1;
TxFocusingAngle = atan(0.1);
Frequency = 5.8e9;
RxAntennaRadius = 0.36;
MaxMode = 4;

%% Display range initialization
TopRange = [(TxAntennaRadius * 2); (TxAntennaRadius * 2); round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 1.4); 0];
BottomRange = [0; 0; round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 0.6); 0];
DisplayRange = [TopRange BottomRange (TopRange - BottomRange) ./ [500; 500; 1; 1]];
DisplayRange(3,3) = 1;

% XZ Plane calculate
XRange = [DisplayRange(1,2) : DisplayRange(1,3) : DisplayRange(1,1)];
ZRange = [DisplayRange(3,2) : DisplayRange(3,3) : DisplayRange(3,1)];

[XZReceiveATotal, IndexMaxRecvA] = OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance, TxFocusingAngle, Frequency, 'A-OAM', MaxMode, DisplayRange);
[XZReceiveDTotal, IndexMaxRecvD] = OAMFocusing(TxChannelNum, TxAntennaRadius, 1, TxBFDistance, TxFocusingAngle, Frequency, 'D-OAM', MaxMode, DisplayRange);
[XZReceiveHTotal, IndexMaxRecvH] = OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance, TxFocusingAngle, Frequency, 'H-OAM', MaxMode, DisplayRange);

RxIndex = round(RxAntennaRadius/DisplayRange(1,3));

Config = ["o" "x" "^" "square"; "#77428D" "#51A8DD" "#EBB471" "#F596AA"; "#77428D" "#51A8DD" "#EBB471" "#F596AA"];

%% FIG 1
figure;
for i = 1 : MaxMode
    plot(ZRange, XRange(IndexMaxRecvA(:,:,:,i)),'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, XRange(IndexMaxRecvD(:,:,:,i)),'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('A-OAM$(l=1)$','D-OAM$(l=1)$','A-OAM$(l=2)$','D-OAM$(l=2)$','A-OAM$(l=3)$','D-OAM$(l=3)$','A-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','NorthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([0 0.65]);
ylabel('Best-receiving Radius $r_{l}$ (m)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 2
figure;
for i = 1 : MaxMode
    plot(ZRange, pow2db(diag(abs(XZReceiveATotal(IndexMaxRecvA(:,:,:,i), :, :, i)))) + 30,'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, pow2db(diag(abs(XZReceiveDTotal(IndexMaxRecvD(:,:,:,i), :, :, i)))) + 30,'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('A-OAM$(l=1)$','D-OAM$(l=1)$','A-OAM$(l=2)$','D-OAM$(l=2)$','A-OAM$(l=3)$','D-OAM$(l=3)$','A-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','SouthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([-40 -20]);
ylabel('Received Power (dBm)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 3
figure;
for i = 1 : MaxMode
    plot(ZRange, pow2db(abs(XZReceiveATotal(RxIndex, :, :, i))) + 30,'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, pow2db(abs(XZReceiveDTotal(RxIndex, :, :, i))) + 30,'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('A-OAM$(l=1)$','D-OAM$(l=1)$','A-OAM$(l=2)$','D-OAM$(l=2)$','A-OAM$(l=3)$','D-OAM$(l=3)$','A-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','SouthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([-55 -25]);
ylabel('Received Power (dBm)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 4
figure;
for i = 1 : MaxMode
    plot(ZRange, XRange(IndexMaxRecvH(:,:,:,i)),'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, XRange(IndexMaxRecvD(:,:,:,i)),'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('H-OAM$(l=1)$','D-OAM$(l=1)$','H-OAM$(l=2)$','D-OAM$(l=2)$','H-OAM$(l=3)$','D-OAM$(l=3)$','H-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','NorthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([0 0.65]);
ylabel('Best-receiving Radius $r_{l}$ (m)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 5
figure;
for i = 1 : MaxMode
    plot(ZRange, pow2db(diag(abs(XZReceiveHTotal(IndexMaxRecvH(:,:,:,i), :, :, i)))) + 30,'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, pow2db(diag(abs(XZReceiveDTotal(IndexMaxRecvD(:,:,:,i), :, :, i)))) + 30,'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('H-OAM$(l=1)$','D-OAM$(l=1)$','H-OAM$(l=2)$','D-OAM$(l=2)$','H-OAM$(l=3)$','D-OAM$(l=3)$','H-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','SouthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([-40 -20]);
ylabel('Received Power (dBm)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 6
figure;
for i = 1 : MaxMode
    plot(ZRange, pow2db(abs(XZReceiveHTotal(RxIndex, :, :, i))) + 30,'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, pow2db(abs(XZReceiveDTotal(RxIndex, :, :, i))) + 30,'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('H-OAM$(l=1)$','D-OAM$(l=1)$','H-OAM$(l=2)$','D-OAM$(l=2)$','H-OAM$(l=3)$','D-OAM$(l=3)$','H-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','SouthWest','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([-55 -25]);
ylabel('Received Power (dBm)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% FIG 7
figure;
for i = 1 : MaxMode
    plot(ZRange, atan(XRange(IndexMaxRecvA(:,:,:,i)) ./ ZRange),'-' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;

    plot(ZRange, atan(XRange(IndexMaxRecvD(:,:,:,i)) ./ ZRange),'--' + Config(1,i),'LineWidth',2,'MarkerSize',10,'Color',Config(2,i),'MarkerEdgeColor',Config(3,i));
    hold on;
end

lgd = legend('A-OAM$(l=1)$','D-OAM$(l=1)$','A-OAM$(l=2)$','D-OAM$(l=2)$','A-OAM$(l=3)$','D-OAM$(l=3)$','A-OAM$(l=4)$','D-OAM$(l=4)$', ...
    'Orientation','horizontal','NumColumns',2,'Location','NorthEast','Interpreter','latex');
lgd.ItemTokenSize = [25 15];
ylim([0 0.07]);
ylabel('Best-receiving Angle (rad)','Interpreter','latex');
xlabel('Receiving Distance $D$ (m)','Interpreter','latex');
grid on;
drawnow;

%% Display range initialization
TopRange = [(TxAntennaRadius * 2); (TxAntennaRadius * 2); round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 1.4); 0];
BottomRange = [(-TxAntennaRadius * 2); (-TxAntennaRadius * 2); round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 0.6); 0];
DisplayRange = [TopRange BottomRange (TopRange - BottomRange) ./ [500; 500; 1; 1]];
DisplayRange(3,3) = (DisplayRange(3,1) - DisplayRange(3,2)) / 500;

% XZ Plane calculate
XRange = [DisplayRange(1,2) : DisplayRange(1,3) : DisplayRange(1,1)];
ZRange = [DisplayRange(3,2) : DisplayRange(3,3) : DisplayRange(3,1)];

[XZReceiveATotal, IndexMaxRecvA] = OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance, TxFocusingAngle, Frequency, 'A-OAM', MaxMode, DisplayRange);
[XZReceiveHTotal, IndexMaxRecvH] = OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance, TxFocusingAngle, Frequency, 'H-OAM', MaxMode, DisplayRange);

%% FIG 8
for i = 1 : MaxMode
    figure;
    surf(ZRange, XRange, pow2db(abs(XZReceiveATotal(:, :, :, i))) + 30);
    shading interp;
    ylabel('Vertical Distance (m)','Interpreter','latex','fontsize',18);
    xlabel('Receiving Distance $D$ (m)','Interpreter','latex','fontsize',18);
    c = colorbar;
    c.Label.String = 'dBm';
    c.Label.Interpreter = 'latex';
    c.Label.FontSize = 18;
    view(0,90);
    clim([-80 -20]);
    daspect([1 1 1]);
    drawnow;
end

%% FIG 9
for i = 1 : MaxMode
    figure;
    surf(ZRange, XRange, pow2db(abs(XZReceiveHTotal(:, :, :, i))) + 30);
    shading interp;
    ylabel('Vertical Distance (m)','Interpreter','latex','fontsize',18);
    xlabel('Receiving Distance $D$ (m)','Interpreter','latex','fontsize',18);
    c = colorbar;
    c.Label.String = 'dBm';
    c.Label.Interpreter = 'latex';
    c.Label.FontSize = 18;
    view(0,90);
    clim([-80 -20]);
    daspect([1 1 1]);
    drawnow;
end


FreeEnvironment;