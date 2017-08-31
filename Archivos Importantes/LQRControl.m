%% Linealizacion de la dinamica del drone
% ===============================
% AUTHOR Fabian Riether
% CREATE DATE 2015/10/30
% PURPOSE This code assists in designing an LQR hover controller
% SPECIAL NOTES

% Carga de parametros del dronde desde el Toolbox de Robotica
mdl_quadrotor


%% 1) Linearize Drone Model
 
 %Cargamos el analisis linear realizado
 load('analisisLinear')
 aux = LinearAnalysisToolProject.Results.Data.Value;
 A = aux.c*aux.a*inv(aux.c);%linsys1.a;
 B = aux.c*aux.b;%linsys1.b;
 C = eye(12);
 D = zeros(12,4);
 

%% 2) Configuracion de la ley de Bryson 

%Limite de los estados
pos_max     = 0.5; %0.5
att_max     = 0.3; %1 y 0.35
dpos_max    = 1;
datt_max    = 1;

motor_max = 500; 

%% Ponderacion de los estados


pos_x_wght        = 0.25/3; 
pos_y_wght        = 0.25/3;
pos_z_wght        = 0.25/3*50; 

orient_ypr_wghts  = 0.175/3;  % Pesos para los tres angulos de euler 

dpos_wghts        = 0.05/3; % Pesos para las velocidades lineales 

dorient_pqr_wghts = 0.4/3; % Pesos para las velocidades de rotacion


rho = 0.01;

%% Normalizacion de la ponderacion
weights = [pos_x_wght pos_y_wght pos_z_wght orient_ypr_wghts orient_ypr_wghts orient_ypr_wghts dpos_wghts dpos_wghts dpos_wghts dorient_pqr_wghts dorient_pqr_wghts dorient_pqr_wghts];
weights = weights/sum(weights); 
maxs    = [pos_max pos_max pos_max att_max att_max att_max dpos_max dpos_max dpos_max datt_max datt_max datt_max];

%% 3) Calculo de las matrices de coste Q y R
Q           = diag((weights)./(maxs));

R           = rho*diag(1./([motor_max motor_max motor_max motor_max]));

%% 4) Calculo de la ganancia del controlador
K_lqr_toMotorcmd       = lqr(A,B,Q,R);
K_lqr_toMotorcmd(abs(K_lqr_toMotorcmd)<(1e-10)) = 0  %Valores pequenos a cero

