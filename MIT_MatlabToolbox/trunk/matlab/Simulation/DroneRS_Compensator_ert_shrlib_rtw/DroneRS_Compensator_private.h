/*
 * File: DroneRS_Compensator_private.h
 *
 * Code generated for Simulink model 'DroneRS_Compensator'.
 *
 * Model version                  : 1.2624
 * Simulink Coder version         : 8.8 (R2015a) 09-Feb-2015
 * C/C++ source code generated on : Mon Aug  7 00:32:07 2017
 *
 * Target selection: ert_shrlib.tlc
 * Embedded hardware selection: 32-bit Generic
 * Emulation hardware selection:
 *    Differs from embedded hardware (MATLAB Host)
 * Code generation objectives:
 *    1. Execution efficiency
 *    2. RAM efficiency
 *    3. ROM efficiency
 * Validation result: Not run
 */

#ifndef RTW_HEADER_DroneRS_Compensator_private_h_
#define RTW_HEADER_DroneRS_Compensator_private_h_
#include "rtwtypes.h"
#include "builtin_typeid_types.h"
#include "multiword_types.h"

/* Private macros used by the generated code to access rtModel */
#ifndef rtmSetTFinal
# define rtmSetTFinal(rtm, val)        ((rtm)->Timing.tFinal = (val))
#endif

#ifndef rtmGetTPtr
# define rtmGetTPtr(rtm)               (&(rtm)->Timing.taskTime0)
#endif

extern real_T rt_atan2d_snf(real_T u0, real_T u1);
extern void DroneRS_Compensa_ControllerFSFB(const real_T rtu_pos_refin[3], const
  real_T rtu_att_refin[3], boolean_T rtu_controlModePosVSAtt_flagin, const
  real_T rtu_states_estimin[2], const real_T rtu_states_estimin_g[2], real_T
  rtu_states_estimin_e, const real_T rtu_states_estimin_f[3], real_T
  rtu_states_estimin_d, const real_T rtu_states_estimin_m[3],
  B_ControllerFSFB_DroneRS_Comp_T *localB, P_ControllerFSFB_DroneRS_Comp_T
  *localP, P_DroneRS_Compensator_T *DroneRS_Compensator_P);
extern void DroneRS_Compe_MeasurementUpdate(boolean_T rtu_Enable, const real_T
  rtu_Lk[4], const real_T rtu_yk[2], const real_T rtu_yhatkk1[2],
  B_MeasurementUpdate_DroneRS_C_T *localB);
extern void DroneRS_Com_UseCurrentEstimator(boolean_T rtu_Enablek, const real_T
  rtu_Mk[4], const real_T rtu_uk[2], const real_T rtu_yk[2], const real_T
  rtu_Ck[4], const real_T rtu_Dk[4], const real_T rtu_xhatkk1[2],
  B_UseCurrentEstimator_DroneRS_T *localB);
extern void DroneR_DroneRS_Compensator_Init(DW_DroneRS_Compensator_DroneR_T
  *localDW, P_DroneRS_Compensator_DroneRS_T *localP);
extern void DroneRS_Com_DroneRS_Compensator(boolean_T
  rtu_controlModePosVSAtt_flagin, const real_T rtu_pos_refin[3], const real_T
  rtu_attRS_refin[3], real_T rtu_sensordataRS_datin, real_T
  rtu_sensordataRS_datin_j, real_T rtu_sensordataRS_datin_n, real_T
  rtu_sensordataRS_datin_jr, real_T rtu_sensordataRS_datin_k, real_T
  rtu_sensordataRS_datin_c, real_T rtu_sensordataRS_datin_g, real_T
  rtu_sensordataRS_datin_gz, const real_T rtu_opticalFlowRS_datin[3], const
  real_T rtu_sensordatabiasRS_datin[7], const real_T rtu_posVIS_datin[4], real_T
  rtu_usePosVIS_flagin, const real_T rtu_batteryStatus_datin[2],
  B_DroneRS_Compensator_DroneRS_T *localB, DW_DroneRS_Compensator_DroneR_T
  *localDW, P_DroneRS_Compensator_DroneRS_T *localP, P_DroneRS_Compensator_T
  *DroneRS_Compensator_P);

#endif                                 /* RTW_HEADER_DroneRS_Compensator_private_h_ */

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
