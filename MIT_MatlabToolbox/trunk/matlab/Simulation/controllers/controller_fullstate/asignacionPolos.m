%% Linearization of drone dynamics about hover & full-state feedback design
% ===============================
% AUTHOR Fabian Riether
% CREATE DATE 2015/08/25
% PURPOSE This code assists in linearizing drone dynamics and designing
% full-state feedback controls
% SPECIAL NOTES
% ===============================
% Change History
%  2015/08/25 created
% ==================================

%Carga de los parametros del drone desde RoboticsToolbox
mdl_quadrotor


%% 1.1) Simplified Dynamics

%Variables simbolicas
syms Pxw Pyw Pzw yaw pitch roll dpx dpy dpz p q r T tauy taup taur;
symsvector  = [Pxw; Pyw; Pzw ;yaw ;pitch ;roll ;dpx ;dpy ;dpz ;p ;q ;r ;T ;tauy ;taup ;taur];

%Transformacion de inercia desde RTB frame a RS frame
J           = ([cos(pi/4) -sin(pi/4) 0; sin(pi/4) cos(pi/4) 0; 0 0 1]'*quad.J*[cos(pi/4) -sin(pi/4) 0; sin(pi/4) cos(pi/4) 0; 0 0 1]);

%Definicion de matrices de rotacion
Ryaw = [
	[ cos(yaw), -sin(yaw), 0],
	[ sin(yaw),  cos(yaw), 0],
	[        0,         0, 1]
];

Rpitch = [
	[  cos(pitch), 0, sin(pitch)],
	[           0, 1,          0],
	[ -sin(pitch), 0, cos(pitch)]
];

Rroll = [
	[ 1,         0,          0],
	[ 0, cos(roll), -sin(roll)],
	[ 0, sin(roll),  cos(roll)]
];

Body2Global = Ryaw*Rpitch*Rroll;
Global2Body = simplify(Body2Global^-1);

% Wronskiano invertido para transformar rotaciones del cuerpo p-q-r a angulos de Euler yaw pitch roll
iW = ...
    [0        sin(roll)          cos(roll);             
     0        cos(roll)*cos(pitch) -sin(roll)*cos(pitch);
     cos(pitch) sin(roll)*sin(pitch) cos(roll)*sin(pitch)] / cos(pitch);

%% Punto de linealizacion 
%-----------
state_equil = [0; 0; -1.5; 0 ;0 ;0 ;0 ;0 ;0 ;0 ;0 ;0 ]; %x_eq
input_equil = [-quad.g*quad.M ;0 ;0 ;0];		%u_eq
equil       = [state_equil; input_equil];

%% Dinamica
%----------      
%P dot      
P_dot           = simplify(Body2Global*[dpx;dpy;dpz]);
P_dot_jacobian  = jacobian(P_dot,symsvector);
P_dot_jacobian_eql = subs(P_dot_jacobian,symsvector,equil);

%O dot      
O_dot           = iW*[p;q;r];
O_dot_jacobian  = jacobian(O_dot,symsvector);
O_dot_jacobian_eql = subs(O_dot_jacobian,symsvector,equil);

%p ddot      
p_ddot          = Global2Body*[0;0;quad.g] + T/quad.M*[0;0;1] -cross(transpose([p,q,r]),transpose([dpx,dpy,dpz]));
p_ddot_jacobian = jacobian(p_ddot,symsvector);
p_ddot_jacobian_eql = subs(p_ddot_jacobian,symsvector,equil);
%o ddot      
o_ddot          = inv(J)*([taur; taup; tauy] - cross([p;q;r],J*[p;q;r]));
o_ddot_jacobian = jacobian(o_ddot,symsvector);
o_ddot_jacobian_eql = subs(o_ddot_jacobian,symsvector,equil);

%Matriz dinamica

matrixAB = [P_dot_jacobian_eql;O_dot_jacobian_eql;p_ddot_jacobian_eql;o_ddot_jacobian_eql];
A = double(matrixAB(1:12,1:12))
B = double(matrixAB(1:12,13:16))

%% 1.2) Linealizacion del modelo

load('analisisLinear.mat');

linsys1 = LinearAnalysisToolProject.Results.Data.Value;

A_fullnlDrone = linsys1.c*linsys1.a*inv(linsys1.c);
B_fullnlDrone = linsys1.c*linsys1.b;

% Los autovalores son: 5 ceros (integradores), 3 estables y 2 inestables
% oscilantes


%% 2.1) Diseno del controlador por asignacion de polos a partir de la dinamica simplificada

% Busqueda de estados a desvincular
[V,J]   = jordan(A);
Veig_nrm = diag(1./sum(V,1))*V; 

% Sistema matricial de estados desvinculados
A_dec   = inv(Veig_nrm)*A*Veig_nrm;
B_dec   = inv(Veig_nrm)*B;

% Definicion de subsistemas desvinculados
A_dec_x   = A_dec(1:4,1:4);
B_dec_x   = B_dec(1:4,1:4);

A_dec_y   = A_dec(7:10,7:10);
B_dec_y   = B_dec(7:10,1:4);

A_dec_z = A_dec(5:6,5:6);
B_dec_z = B_dec(5:6,1:4);

A_dec_yaw = A_dec(11:12,11:12);
B_dec_yaw = B_dec(11:12,1:4);

% Asignacion de los polos deseados

xpoles      = [-9+6i;-9-6i;-0.18+1.8i;-0.18-1.8i];
ypoles      = [-60;-4;-0.1+2i;-0.1-2i];   
yawpoles    = [-3;-3.1];
%yawpoles    = [-5;-5.1];  % Posible modificacion, mejor control de yaw
%zpoles    = [-2;-2.1];    % Control en altura lento          
zpoles    = [-5;-5.1];     % Control en altura rapido          


K_dec_x     = place(A_dec_x,B_dec_x,xpoles);
K_dec_y     = place(A_dec_y,B_dec_y,ypoles);
K_dec_z     = place(A_dec_z,B_dec_z,zpoles);
K_dec_yaw   = place(A_dec_yaw,B_dec_yaw,yawpoles);

% Calculo de controlador original
K_poleplace = [K_dec_x K_dec_z K_dec_y K_dec_yaw]*inv(Veig_nrm);
K_poleplace(abs(K_poleplace)<1e-10)=0;

%The difference between the two controllers is only in z-dynamics. We
%expect the controller with z-poles {-5;-5.1} to be stronger/faster than
%the one with z-poles {-3;-3.1}. As the z-subsystem acts on states Z and
%zdot, the only difference that we see in the K matrices are the elements
%relating to the states Z and zdot.

%Se imprime la ganancia en pantalla
K_poleplace

% Generacion de formato listo para codigo en c para rsedu_control.c
K_poleplace_string = sprintf('%E,' , K_poleplace(:));
K_poleplace_string = ['{ ' K_poleplace_string(1:end-1) ' }']
