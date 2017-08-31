%% Graficos de posiciones XYZ
close all
x = simPos.X.Data;
y = simPos.Y.Data;
z = simPos.Z.Data;
t = simPos.X.Time;
ref = referenciasAltura.Data;

plot(t,x,t,y,t,z,t,ref)
legend('X','Y','Z', 'Referencia');
title('Posicion XYZ')
xlabel('Tiempo (s)');
ylabel('Posicion (m)');
axis([-1 20 -2 0.5]);

%% X frente Y

close all
x = simPos.X.Data;
y = simPos.Y.Data;
z = simPos.Z.Data;
t = simPos.X.Time;
yaw = simAng.Data(:,1);
ref = referenciasAltura.Data;
c = length(t);
h= plot(x,y,x(1,1),y(1,1),'kx',x(c,1),y(c,1),'rx');
set(h(2),'MarkerSize',6,'LineWidth',3);
set(h(3),'MarkerSize',6,'LineWidth',3);

 axis([-5 5 -5 5]);
axis([-10 10 -10 10]);
legend('Trayectoria','Inicio','Fin');

title('Trayectoria Cuadrada')
xlabel('Posicion X (m)');
ylabel('Posicion Y (m)');

inicio=[x(1,1),y(1,1)];
fin = [x(c,1),y(c,1)];
error = inicio-fin;
err = sqrt(error(1)^2 + error(2)^2)

%% Yaw Pitch y roll
close all
yaw = simAng.Data(:,1);
pitch = simAng.Data(:,2);
roll = simAng.Data(:,3);
t = simPos.X.Time;
refYaw = refAngulos.Data(:,1);
refPitch = refAngulos.Data(:,2);
refRoll = refAngulos.Data(:,3);


plot(t,yaw,'-',t,pitch,'-',t,roll,'-');
hold on
plot(t,refYaw,'--',t,refPitch,'--',t,refRoll,'--');

%axis([-5 5 -5 5]);
%axis([-20 20 -20 20]);
legend('Yaw','Pitch','Roll','Referencia Yaw','Referencia Pitch','Referencia Roll');

title('Angulos Yaw, Pitch y Roll')
xlabel('Tiempo (s)');
ylabel('Angulo (rad)');


