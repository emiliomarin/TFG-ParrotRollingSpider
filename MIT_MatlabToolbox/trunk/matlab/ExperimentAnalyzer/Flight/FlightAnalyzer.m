%% Analyze Sensordata
% ===============================
% AUTHOR Fabian Riether
% CREATE DATE 2015/08/25
% PURPOSE This scripts plots tons of data from a flight data saved to a
% RSdata.mat-file onboard the drone. Additionaly, it rearranges data to be
% used in the SoftwareinTheLoop_Compensator simulink model
% SPECIAL NOTES
% ===============================
% Change History
%  2015/08/25 created
% ==================================




%% Rearrange data
%Load all parameters
paramsFilters;

%Aug31rst+ recordings file version
if ( size(rt_yout.signals,2)>24)
    RSrun_motorcommands = [rt_yout.time rt_yout.signals(1).values];
    RSrun_controlMode   = [rt_yout.time,rt_yout.signals(14).values];
    RSrun_attRS_ref     = [rt_yout.time,rt_yout.signals(15).values(:,4:6)];
    RSrun_pos_ref       = [rt_yout.time,rt_yout.signals(15).values(:,1:3)];
    RSrun_sensordataRS  = [rt_yout.time rt_yout.signals(16).values rt_yout.signals(17).values rt_yout.signals(18).values rt_yout.signals(19).values rt_yout.signals(20).values permute(rt_yout.signals(21).values,[ 1 2 3]) permute(rt_yout.signals(22).values,[1 2 3]) rt_yout.signals(23).values ];    
    RSrun_opticalFlowRS = [rt_yout.time,rt_yout.signals(24).values];
    RSrun_sensorBiasRS  = [rt_yout.signals(25).values(1,:)];
    RSrun_posVIS        = [rt_yout.time,rt_yout.signals(26).values];   
    RSrun_usePosVIS     = [rt_yout.time,rt_yout.signals(27).values];

    RSrun_states_estim  = rt_yout.time;
    for i=2:13
        RSrun_states_estim = [RSrun_states_estim rt_yout.signals(i).values];
    end;
    
    if (size(rt_yout.signals,2)==28)
        RSrun_batteryStatus = [rt_yout.time,rt_yout.signals(28).values];   
    end;

%--old recordings-file-version
elseif (size(rt_yout.signals(2).values,2)==1)

    RSrun_sensordataRS  = [rt_yout.time rt_yout.signals(2).values rt_yout.signals(3).values rt_yout.signals(4).values rt_yout.signals(5).values rt_yout.signals(6).values permute(rt_yout.signals(7).values,[ 1 2 3]) permute(rt_yout.signals(8).values,[1 2 3]) rt_yout.signals(9).values ];
    RSrun_attRS_ref     = [rt_yout.time,rt_yout.signals(22).values(:,4:6)];
    RSrun_pos_ref       = [rt_yout.time,rt_yout.signals(22).values(:,1:3)];
    RSrun_controlMode   = [rt_yout.time,((RSrun_pos_ref(:,1)~=0) & (RSrun_pos_ref(:,2)~=0))];
    RSrun_motorcommands = [rt_yout.time rt_yout.signals(1).values];
    RSrun_opticalFlowRS = [rt_yout.time,rt_yout.signals(23).values];
    RSrun_posVIS        = [rt_yout.time,rt_yout.signals(24).values];

    RSrun_states_estim  = rt_yout.time;

    for i=10:21
        RSrun_states_estim = [RSrun_states_estim rt_yout.signals(i).values];
    end;
    
%--Aug 14-Aug 31rst recordings-file-version
else
 
    RSrun_sensordataRS  = [rt_yout.time rt_yout.signals(3).values rt_yout.signals(4).values rt_yout.signals(5).values rt_yout.signals(6).values rt_yout.signals(7).values permute(rt_yout.signals(8).values,[ 1 2 3]) permute(rt_yout.signals(9).values,[1 2 3]) rt_yout.signals(10).values ];
    RSrun_motorcommands = [rt_yout.time rt_yout.signals(1).values];
    RSrun_opticalFlowRS = [rt_yout.time,rt_yout.signals(23).values];
    RSrun_posVIS        = [rt_yout.time,rt_yout.signals(24).values];
    RSrun_attRS_ref     = [rt_yout.time,rt_yout.signals(2).values(:,4:6)];
    RSrun_pos_ref       = [rt_yout.time,rt_yout.signals(2).values(:,1:3)];
    RSrun_controlMode   = [rt_yout.time,((RSrun_pos_ref(:,1)~=0) & (RSrun_pos_ref(:,2)~=0))];

    RSrun_states_estim  = rt_yout.time;
    for i=11:22
        RSrun_states_estim = [RSrun_states_estim rt_yout.signals(i).values];
    end;
end;

%% accelerometer, gyro, attitude, motor commands
visUpdatesAvlble = (RSrun_posVIS(:,2)~=-99);

figure('Name','Sensors, Motors');

%accelerometer
h(1)=subplot(4,1,1);
plot(RSrun_sensordataRS(:,1),RSrun_sensordataRS(:,2:4))
ylabel 'IMU-accel'
xlabel 't [s]'
legend({'$\ddot x$' '$\ddot y$' '$\ddot z$'},'Interpreter','latex');
ylim([-12 12])
title('IMU, attitude, motor commands');

%gyro
h(2)=subplot(4,1,2);
plot(RSrun_sensordataRS(:,1),RSrun_sensordataRS(:,5:end-2))
ylabel 'IMU-gyro'
xlabel 't [s]'
legend({ '$w_x$' '$w_y$' '$w_z$'},'Interpreter','latex');
ylim([-1 1])

%stateestimates
h(3)=subplot(4,1,3);

title('Control de angulos');
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,5:7),'.-'); hold all;
plot(RSrun_posVIS(visUpdatesAvlble,1),RSrun_posVIS(visUpdatesAvlble,5),'o');
plot(RSrun_attRS_ref(:,1),RSrun_attRS_ref(:,2:end));

ylabel 'Angulos de orientacion'
if (any(visUpdatesAvlble))
    plot(RSrun_posVIS(visUpdatesAvlble,1),RSrun_posVIS(visUpdatesAvlble,5),'o');
    legend({'yaw $\hat{\psi}$' 'pitch $\hat{\theta}$' 'roll $\hat{\phi}$' '$\psi_{d}$' '$\theta_{d}$' '$\phi_{d}$' '$\hat{\psi}_{VIS}$'  },'Interpreter','latex');
else
    legend({'yaw' 'pitch' 'roll' 'yaw_{ref}' 'pitch_{ref}' 'roll_{ref}'});
end;
xlabel 'Tiempo [s]'
ylim([-2 2])

%motorcommands
h(4)=subplot(4,1,4);
plot(RSrun_motorcommands(:,1),RSrun_motorcommands(:,2:end));
ylabel 'motor commands'
xlabel 't [s]'
legend({'m_1' 'm_2' 'm_3' 'm_4'});
ylim([-600 600])

linkaxes([h(1) h(2) h(3) h(4)],'x');


%% Altitude

figure('Name','Control de altura');

    
% altitude from pressure (for comparison only)
altPrs = (RSrun_sensordataRS(:,9) - RSrun_sensorBiasRS(1,7))/(quadEDT.altToPrs_Gain);    
hold off;
plot(rt_tout, altPrs); hold all;    
% altitude from sonar
plot(rt_tout, -RSrun_sensordataRS(:,8),'LineWidth',2);

% altitude from KF
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,4),'LineWidth',3);

% altitude reference
plot(RSrun_pos_ref(:,1),RSrun_pos_ref(:,4),'g','LineWidth',2);

% altitude from vision
visUpdatesAvlble = (RSrun_posVIS(:,2)~=-99);
plot(RSrun_posVIS(visUpdatesAvlble,1),-RSrun_posVIS(visUpdatesAvlble,4),'o','LineWidth',3);

legend({'Presion'  'Ultrasonico' 'Estimacion de Kalman $\hat z$' 'Referencia $z_{desired}$'  },'Interpreter','latex');
ylim([-3.5 1]);
xlabel 'Tiempo (s)'
ylabel 'Altura (m)'
title 'Control de altura'

%% 2D Position & Velocity
visUpdatesAvlble = (RSrun_posVIS(:,2)~=-99);
    
figure('Name','Positions & Velocities','Position',[100 100 600 700]);
subplot(6,1,1:2);

%Trajectory
plot(RSrun_states_estim(:,3),RSrun_states_estim(:,2));
hold all;
plot(RSrun_states_estim(1,3),RSrun_states_estim(1,2),'rx');
plot(RSrun_states_estim(end,3),RSrun_states_estim(end,2),'gx');
plot(RSrun_posVIS(visUpdatesAvlble,3),RSrun_posVIS(visUpdatesAvlble,2),'o-');
set(gca,'xaxisLocation','top')
legend({'$\hat{Pos}$','start','finish','$\hat{Pos}_{VIS}$'},'Interpreter', 'latex')
ylim([-.3 .3]);
xlabel({'$Y$ [m]'},'Interpreter','latex');
ylabel({'$X$ [m]'},'Interpreter','latex');
axis equal

%Positions
h(1)=subplot(12,1,5:6);
axis normal
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,2));hold all;
plot(RSrun_posVIS(visUpdatesAvlble,1),RSrun_posVIS(visUpdatesAvlble,2),'o'); 
legend({'$\hat{X}$','$\hat{X}_{VIS}$'},'Interpreter','latex')
ylim([-.7 .7])
ylabel({'$X$ [m]'},'Interpreter','latex');

h(2)=subplot(12,1,7:8);
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,3));   hold all;
plot(RSrun_posVIS(visUpdatesAvlble,1),RSrun_posVIS(visUpdatesAvlble,3),'o');
legend({'$\hat{Y}$','$\hat{Y}_{VIS}$'},'Interpreter','latex')
ylim([-.5 .5])
ylabel({'$Y$ [m]'},'Interpreter','latex');

%Velocities
h(3)=subplot(12,1,9:10);
plot(RSrun_opticalFlow(:,1),20*RSrun_opticalFlow(:,2),'.-'); hold all;
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,8));
ylabel('$\dot x$ [m/s]','Interpreter','latex');
legend({'$\dot{x}_{opt. flow}$' '$\hat{\dot x}$'},'Interpreter','latex');

h(4)=subplot(12,1,11:12);
plot(RSrun_opticalFlow(:,1),20*RSrun_opticalFlow(:,3),'.-'); hold all;
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,9));
xlabel({'t [s]'},'Interpreter','latex');
ylabel('$\dot y$ [m/s]','Interpreter','latex');
legend({'$\dot{y}_{opt. flow}$' '$\hat{\dot y}$'},'Interpreter','latex');

set(h(1:end-1),'xticklabel',[])
linkaxes(h,'x');

%% Optical Flow, Velocity

eps = 1e-10;
figure('Name','Optical Flow');

plot(RSrun_opticalFlowRS(:,1),1/quadEDT.VelocityToOpticalFlow_Gain*RSrun_opticalFlowRS(:,2:3),'-'); hold all;
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,8),'.-');
plot(RSrun_states_estim(:,1),RSrun_states_estim(:,9),'.-');

title 'Optical flow and velocity'
legend({'optical flow$_x$' 'optical flow$_y$' '$\dot x$' '$\dot y$'},'Interpreter', 'latex');
xlabel 't [s]'
ylabel '[m/s]'

%% Battery statys
figure;

plot(RSrun_batteryStatus(:,1),RSrun_batteryStatus(:,3));

title 'Battery voltage'
legend('Battery voltage');
xlabel 't [s]'
ylabel '%'

